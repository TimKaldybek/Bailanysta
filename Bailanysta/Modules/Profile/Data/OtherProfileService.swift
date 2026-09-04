//
//  OtherProfileService.swift
//  Bailanysta
//

import FirebaseFirestore
import Foundation

/// Looks a user up by `handle` in Firestore and reads their `posts`. A stale/bad handle (no
/// matching `users` document) is a real, non-error state — it's mapped to an empty/default
/// profile rather than treated as a failure.
final class OtherProfileService {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    /// - Throws: only on a genuine read failure (e.g. transient network error) — a handle with no
    ///   matching `users` document is a valid state and returns an empty-profile DTO instead of
    ///   throwing.
    func loadUser(handle: String) async throws -> OtherProfileDTO {
        guard let document = try await findUserDocument(handle: handle) else {
            return OtherProfileDTO(user: Self.emptyUser(), posts: [], likes: [], replies: [])
        }

        let posts = try await loadPosts(authorId: document.documentID)
        let isFollowing = await isCurrentUserFollowing(targetUid: document.documentID)
        let user = Self.mapUser(
            id: document.documentID,
            data: document.data(),
            postsCount: posts.count,
            isFollowing: isFollowing
        )
        let likes = await loadLikedPosts(uid: document.documentID)
        let replies = await loadReplies(uid: document.documentID)

        return OtherProfileDTO(user: user, posts: posts, likes: likes, replies: replies)
    }

    /// - Parameter isFollowing: the *current* follow state, as already tracked by the Presenter —
    ///   determines whether this call unfollows or follows, mirroring `FeedLikeService.toggleLike`.
    /// - Returns: the new `isFollowing` state (`!isFollowing`).
    /// - Throws: `OtherProfileServiceError` for a missing session/profile or a self-follow attempt,
    ///   or a genuine Firestore write failure.
    func toggleFollow(targetUid: String, isFollowing: Bool) async throws -> Bool {
        guard let currentUid = SessionManager.shared.currentUserID else {
            throw OtherProfileServiceError.notSignedIn
        }
        guard currentUid != targetUid else {
            throw OtherProfileServiceError.cannotFollowSelf
        }

        let currentUserReference = firestore.collection(Constants.usersCollection).document(currentUid)
        let currentUserSnapshot = try await currentUserReference.getDocument()
        guard currentUserSnapshot.exists else {
            throw OtherProfileServiceError.missingCurrentUserProfile
        }

        let batch = makeToggleFollowBatch(currentUid: currentUid, targetUid: targetUid, isFollowing: isFollowing)
        try await commit(batch)

        return !isFollowing
    }
}

// MARK: - Errors

enum OtherProfileServiceError: Error {
    case notSignedIn
    case cannotFollowSelf
    /// `users/{currentUid}` doesn't exist — an anonymous guest without a profile document can't
    /// follow anyone, since the batch's counter update requires the document to exist.
    case missingCurrentUserProfile
}

// MARK: - Private

private extension OtherProfileService {
    /// A handle with no matching document is a valid empty state (`return nil`), a Firestore read
    /// error is a genuine failure and propagates (`throw`) so the caller can keep its last-known-good data.
    func findUserDocument(handle: String) async throws -> QueryDocumentSnapshot? {
        let snapshot = try await firestore.collection(Constants.usersCollection)
            .whereField("handle", isEqualTo: handle)
            .limit(to: 1)
            .getDocuments()
        return snapshot.documents.first
    }

    /// No session or a failed read both degrade to `false` — the follow state is display-only
    /// here, not worth failing the whole profile load over.
    func isCurrentUserFollowing(targetUid: String) async -> Bool {
        guard let currentUid = SessionManager.shared.currentUserID else { return false }
        let snapshot = try? await firestore.collection(Constants.usersCollection).document(currentUid)
            .collection(Constants.followingCollection).document(targetUid)
            .getDocument()
        return snapshot?.exists ?? false
    }

    /// Builds the 4-write batch: the `following`/`followers` subcollection docs and both users'
    /// counters move together atomically. `isFollowing` is the state *before* this toggle.
    func makeToggleFollowBatch(currentUid: String, targetUid: String, isFollowing: Bool) -> WriteBatch {
        let batch = firestore.batch()

        let followingReference = firestore.collection(Constants.usersCollection).document(currentUid)
            .collection(Constants.followingCollection).document(targetUid)
        let followersReference = firestore.collection(Constants.usersCollection).document(targetUid)
            .collection(Constants.followersCollection).document(currentUid)
        let currentUserReference = firestore.collection(Constants.usersCollection).document(currentUid)
        let targetUserReference = firestore.collection(Constants.usersCollection).document(targetUid)

        if isFollowing {
            batch.deleteDocument(followingReference)
            batch.deleteDocument(followersReference)
            batch.updateData(["followingCount": FieldValue.increment(Int64(-1))], forDocument: currentUserReference)
            batch.updateData(["followersCount": FieldValue.increment(Int64(-1))], forDocument: targetUserReference)
        } else {
            batch.setData(["createdAt": FieldValue.serverTimestamp()], forDocument: followingReference)
            batch.setData(["createdAt": FieldValue.serverTimestamp()], forDocument: followersReference)
            batch.updateData(["followingCount": FieldValue.increment(Int64(1))], forDocument: currentUserReference)
            batch.updateData(["followersCount": FieldValue.increment(Int64(1))], forDocument: targetUserReference)
        }

        return batch
    }

    /// Оборачивает closure-based `WriteBatch.commit` в `async throws`, аналогично тому как
    /// `ProfileService.put(_:to:)` оборачивает `StorageReference.putData` — используемая версия
    /// FirebaseFirestore не предоставляет async-перегрузку для `commit`.
    func commit(_ batch: WriteBatch) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            batch.commit { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    func loadPosts(authorId: String) async throws -> [ProfilePostDTO] {
        let snapshot = try await firestore.collection(Constants.postsCollection)
            .whereField("authorId", isEqualTo: authorId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.map(Self.mapPost)
    }

    /// Likes is a secondary, non-critical tab — a genuine read failure degrades to an empty
    /// array rather than failing the whole profile load.
    func loadLikedPosts(uid: String) async -> [ProfilePostDTO] {
        guard let snapshot = try? await firestore.collection(Constants.postsCollection)
            .whereField("likedByUserIds", arrayContains: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        else { return [] }
        return snapshot.documents.map(Self.mapPost)
    }

    /// Replies is a secondary, non-critical tab — a genuine read failure degrades to an empty
    /// array rather than failing the whole profile load. Uses a collection group query since
    /// comments live under each post's `comments` subcollection.
    func loadReplies(uid: String) async -> [ProfilePostDTO] {
        guard let snapshot = try? await firestore.collectionGroup(Constants.commentsCollectionGroup)
            .whereField("authorId", isEqualTo: uid)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        else { return [] }
        return snapshot.documents.map(Self.mapReply)
    }

    static func emptyUser() -> OtherProfileUserDTO {
        OtherProfileUserDTO(
            id: UUID().uuidString,
            name: "",
            handle: "",
            tagline: "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: nil,
            followersCount: 0,
            followingCount: 0,
            postsCount: 0,
            isFollowing: false
        )
    }

    static func mapUser(id: String, data: [String: Any], postsCount: Int, isFollowing: Bool) -> OtherProfileUserDTO {
        OtherProfileUserDTO(
            id: id,
            name: data["name"] as? String ?? "",
            handle: data["handle"] as? String ?? "",
            tagline: "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: data["avatarURL"] as? String,
            followersCount: data["followersCount"] as? Int ?? 0,
            followingCount: data["followingCount"] as? Int ?? 0,
            postsCount: postsCount,
            isFollowing: isFollowing
        )
    }

    static func mapPost(_ document: QueryDocumentSnapshot) -> ProfilePostDTO {
        let data = document.data()

        return ProfilePostDTO(
            id: document.documentID,
            authorName: data["authorName"] as? String ?? "",
            authorHandle: data["authorHandle"] as? String ?? "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: data["authorAvatarURL"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
            text: data["text"] as? String ?? "",
            // attachmentImageURL пока не рендерится — вложения постов вне скоупа этой миграции
            attachmentImageName: nil,
            commentsCount: data["commentsCount"] as? Int ?? 0,
            repostsCount: data["repostsCount"] as? Int ?? 0,
            likesCount: data["likesCount"] as? Int ?? 0,
            viewsCount: data["viewsCount"] as? Int ?? 0,
            replyingToHandle: nil,
            parentPostId: nil
        )
    }

    /// A comment document, displayed as a `ProfilePost` on the Replies tab — a reply has no
    /// engagement counters of its own in this schema and no attachments.
    static func mapReply(_ document: QueryDocumentSnapshot) -> ProfilePostDTO {
        let data = document.data()

        return ProfilePostDTO(
            id: document.documentID,
            authorName: data["authorName"] as? String ?? "",
            authorHandle: data["authorHandle"] as? String ?? "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: data["authorAvatarURL"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
            text: data["text"] as? String ?? "",
            attachmentImageName: nil,
            commentsCount: 0,
            repostsCount: 0,
            likesCount: 0,
            viewsCount: 0,
            replyingToHandle: data["postAuthorHandle"] as? String,
            parentPostId: document.reference.parent.parent?.documentID
        )
    }
}

// MARK: - Constants

private extension OtherProfileService {
    enum Constants {
        static let usersCollection = "users"
        static let postsCollection = "posts"
        static let followingCollection = "following"
        static let followersCollection = "followers"
        static let commentsCollectionGroup = "comments"
        static let defaultAvatarImageName = "person.crop.circle.fill"
    }
}
