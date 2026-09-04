//
//  FeedPostsService.swift
//  Bailanysta
//

import FirebaseFirestore
import Foundation

/// Reads posts from the shared `posts` Firestore collection, newest first. Mirrors
/// `ProfileService.loadPosts`'s read/mapping style.
final class FeedPostsService {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }
    
    func loadData() async throws -> [FeedPostDTO] {
        let snapshot = try await firestore.collection(Constants.postsCollection)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.map(Self.map)
    }

    func observePosts() -> AsyncStream<Result<[FeedPostDTO], Error>> {
        AsyncStream { continuation in
            let registration = firestore.collection(Constants.postsCollection)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.yield(.failure(error))
                        return
                    }
                    guard let snapshot else { return }
                    continuation.yield(.success(snapshot.documents.map(Self.map)))
                }

            continuation.onTermination = { _ in
                registration.remove()
            }
        }
    }
}

// MARK: - Private

private extension FeedPostsService {
    static func map(_ document: QueryDocumentSnapshot) -> FeedPostDTO {
        let data = document.data()
        let likedByUserIds = data["likedByUserIds"] as? [String] ?? []
        let currentUserID = SessionManager.shared.currentUserID ?? ""

        return FeedPostDTO(
            id: document.documentID,
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

private extension FeedPostsService {
    enum Constants {
        static let postsCollection = "posts"
        static let defaultAvatarImageName = "person.crop.circle.fill"
    }
}
