//
//  FeedLikeService.swift
//  Bailanysta
//

import FirebaseFirestore
import Foundation

/// Atomically toggles the current user's like on a `posts/{postID}` document via a Firestore
/// transaction, so concurrent toggles on the same post never race on `likesCount`.
final class FeedLikeService {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    /// - Parameter isLiked: the post's *current* like state, as already tracked by the Presenter —
    ///   determines whether this toggle removes or adds the current user's like, so the service
    ///   doesn't need an extra read before starting the transaction.
    /// - Throws: `FeedLikeServiceError.notSignedIn` if there's no session, or a genuine Firestore
    ///   transaction failure.
    func toggleLike(postID: String, isLiked: Bool) async throws -> FeedPostDTO {
        guard let uid = SessionManager.shared.currentUserID else {
            throw FeedLikeServiceError.notSignedIn
        }

        let reference = firestore.collection(Constants.postsCollection).document(postID)
        let data = try await runToggleTransaction(reference: reference, uid: uid, isLiked: isLiked)

        // `isLiked` here is the *pre*-toggle state, so `!isLiked` means this call just added a
        // like — that's the only direction worth notifying the author about. Detached so a slow
        // notification write never adds latency to the like itself.
        if !isLiked {
            Task { await self.notifyAuthorOfLike(postData: data, likerUID: uid) }
        }

        return Self.map(id: postID, data: data)
    }
}

// MARK: - Errors

enum FeedLikeServiceError: Error {
    case notSignedIn
    /// The transaction completed without an error but also without the expected result payload —
    /// not expected in practice, kept only so `runToggleTransaction` never force-unwraps.
    case transactionFailed
}

// MARK: - Private

private extension FeedLikeService {
    /// Оборачивает closure-based `Firestore.runTransaction` в `async throws`, аналогично тому как
    /// `ProfileService.put(_:to:)` оборачивает `StorageReference.putData`. Читает документ внутри
    /// транзакции (не заранее), чтобы атомарно клэмпить `likesCount` на 0 и не потерять
    /// конкурентное изменение.
    func runToggleTransaction(reference: DocumentReference, uid: String, isLiked: Bool) async throws -> [String: Any] {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String: Any], Error>) in
            firestore.runTransaction({ transaction, errorPointer -> Any? in
                do {
                    let snapshot = try transaction.getDocument(reference)
                    var data = snapshot.data() ?? [:]

                    let currentLikesCount = data["likesCount"] as? Int ?? 0
                    var likedByUserIds = data["likedByUserIds"] as? [String] ?? []

                    if isLiked {
                        likedByUserIds.removeAll { $0 == uid }
                    } else if !likedByUserIds.contains(uid) {
                        likedByUserIds.append(uid)
                    }
                    let newLikesCount = max(0, currentLikesCount + (isLiked ? -1 : 1))

                    transaction.updateData([
                        "likedByUserIds": likedByUserIds,
                        "likesCount": newLikesCount
                    ], forDocument: reference)

                    data["likedByUserIds"] = likedByUserIds
                    data["likesCount"] = newLikesCount
                    return data
                } catch {
                    errorPointer?.pointee = error as NSError
                    return nil
                }
            }, completion: { result, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let data = result as? [String: Any] {
                    continuation.resume(returning: data)
                } else {
                    continuation.resume(throwing: FeedLikeServiceError.transactionFailed)
                }
            })
        }
    }

    /// Best-effort — a failed notification write must never fail the like itself, so errors are
    /// swallowed rather than thrown.
    func notifyAuthorOfLike(postData: [String: Any], likerUID: String) async {
        guard let authorId = postData["authorId"] as? String, authorId != likerUID else { return }

        let likerName = try? await loadUserName(uid: likerUID)
        let postPreviewText = postData["text"] as? String ?? ""

        try? await firestore
            .collection(Constants.usersCollection).document(authorId)
            .collection(Constants.notificationsCollection).document(UUID().uuidString)
            .setData([
                "kind": "like",
                "actorName": likerName ?? "",
                "postPreviewText": postPreviewText,
                "createdAt": FieldValue.serverTimestamp(),
                "isUnread": true
            ])
    }

    func loadUserName(uid: String) async throws -> String {
        let snapshot = try await firestore.collection(Constants.usersCollection).document(uid).getDocument()
        return snapshot.data()?["name"] as? String ?? ""
    }

    static func map(id: String, data: [String: Any]) -> FeedPostDTO {
        let likedByUserIds = data["likedByUserIds"] as? [String] ?? []
        let currentUserID = SessionManager.shared.currentUserID ?? ""

        return FeedPostDTO(
            id: id,
            authorName: data["authorName"] as? String ?? "",
            authorHandle: data["authorHandle"] as? String ?? "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: data["authorAvatarURL"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
            text: data["text"] as? String ?? "",
            attachmentImageName: nil,
            attachmentImageURL: data["attachmentImageURL"] as? String,
            voiceMessageURL: data["voiceMessageURL"] as? String,
            voiceMessageDuration: data["voiceMessageDuration"] as? TimeInterval,
            likesCount: data["likesCount"] as? Int ?? 0,
            isLiked: likedByUserIds.contains(currentUserID),
            commentsCount: data["commentsCount"] as? Int ?? 0
        )
    }
}

// MARK: - Constants

private extension FeedLikeService {
    enum Constants {
        static let postsCollection = "posts"
        static let usersCollection = "users"
        static let notificationsCollection = "notifications"
        static let defaultAvatarImageName = "person.crop.circle.fill"
    }
}
