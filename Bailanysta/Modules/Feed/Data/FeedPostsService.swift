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

    /// - Parameter filter: `.category` filters server-side via an exact Firestore field match
    ///   (e.g. from a tapped Trending Searches topic); `.keyword` filters client-side against each
    ///   post's `text` since Firestore has no substring/full-text index; `nil` loads the
    ///   unfiltered feed.
    func loadData(filter: FeedFilter? = nil) async throws -> [FeedPostDTO] {
        let snapshot = try await postsQuery(filter: filter)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        let posts = snapshot.documents.map(Self.map)
        return Self.applyClientSideFilter(filter, to: posts)
    }

    func observePosts(filter: FeedFilter? = nil) -> AsyncStream<Result<[FeedPostDTO], Error>> {
        AsyncStream { continuation in
            let registration = postsQuery(filter: filter)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.yield(.failure(error))
                        return
                    }
                    guard let snapshot else { return }
                    let posts = snapshot.documents.map(Self.map)
                    continuation.yield(.success(Self.applyClientSideFilter(filter, to: posts)))
                }

            continuation.onTermination = { _ in
                registration.remove()
            }
        }
    }
}

// MARK: - Private

private extension FeedPostsService {
    func postsQuery(filter: FeedFilter?) -> Query {
        let collection = firestore.collection(Constants.postsCollection)

        switch filter {
        case .category(let category):
            return collection.whereField("category", isEqualTo: category)
        case .keyword:
            return collection.limit(to: Constants.keywordSearchLimit)
        case nil:
            return collection
        }
    }

    /// `.category` is already narrowed server-side by `postsQuery`; `.keyword` has no server-side
    /// index and must be matched here against each post's raw `text`.
    static func applyClientSideFilter(_ filter: FeedFilter?, to posts: [FeedPostDTO]) -> [FeedPostDTO] {
        guard case .keyword(let keyword) = filter else { return posts }

        let normalizedKeyword = keyword.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !normalizedKeyword.isEmpty else { return posts }

        return posts.filter { $0.text.lowercased().contains(normalizedKeyword) }
    }

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
        /// Bounds reads for an unindexed keyword search since there's no server-side text index.
        static let keywordSearchLimit = 300
    }
}
