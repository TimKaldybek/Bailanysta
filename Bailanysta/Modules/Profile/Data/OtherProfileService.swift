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
        let user = Self.mapUser(id: document.documentID, data: document.data(), postsCount: posts.count)

        return OtherProfileDTO(user: user, posts: posts, likes: [], replies: [])
    }
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

    func loadPosts(authorId: String) async throws -> [ProfilePostDTO] {
        let snapshot = try await firestore.collection(Constants.postsCollection)
            .whereField("authorId", isEqualTo: authorId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        return snapshot.documents.map(Self.mapPost)
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

    static func mapUser(id: String, data: [String: Any], postsCount: Int) -> OtherProfileUserDTO {
        OtherProfileUserDTO(
            id: id,
            name: data["name"] as? String ?? "",
            handle: data["handle"] as? String ?? "",
            tagline: "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: data["avatarURL"] as? String,
            followersCount: 0,
            followingCount: 0,
            postsCount: postsCount,
            isFollowing: false
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
            replyingToHandle: nil
        )
    }
}

// MARK: - Constants

private extension OtherProfileService {
    enum Constants {
        static let usersCollection = "users"
        static let postsCollection = "posts"
        static let defaultAvatarImageName = "person.crop.circle.fill"
    }
}
