//
//  CommentsService.swift
//  Bailanysta
//

import FirebaseFirestore
import Foundation

/// Reads/writes the `posts/{postID}/comments` subcollection. Mirrors `FeedPostsService`'s
/// read style and `FeedPostSubmissionService`'s denormalized-author write style.
final class CommentsService {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    /// Oldest first — a comment thread reads chronologically.
    /// - Throws: only on a genuine read failure — an empty subcollection is a valid state and
    ///   returns an empty array instead of throwing.
    func loadData(postID: String) async throws -> [CommentDTO] {
        let snapshot = try await commentsCollection(postID: postID)
            .order(by: "createdAt", descending: false)
            .getDocuments()
        return snapshot.documents.map(Self.map)
    }

    /// - Throws: `CommentsServiceError.notSignedIn` if there's no session, or a genuine Firestore
    ///   write failure.
    func addComment(postID: String, text: String) async throws -> CommentDTO {
        guard let uid = SessionManager.shared.currentUserID else {
            throw CommentsServiceError.notSignedIn
        }

        let author = try await loadAuthor(uid: uid)
        let postAuthorHandle = await loadPostAuthorHandle(postID: postID)
        let createdAt = Date()

        let reference = try await commentsCollection(postID: postID).addDocument(data: [
            "authorId": uid,
            "authorName": author.name,
            "authorHandle": author.handle,
            "authorAvatarURL": author.avatarURL as Any,
            "postAuthorHandle": postAuthorHandle as Any,
            "text": text,
            "createdAt": FieldValue.serverTimestamp()
        ])

        try await firestore.collection(Constants.postsCollection).document(postID).updateData([
            "commentsCount": FieldValue.increment(Int64(1))
        ])

        // Detached so a slow notification write never adds latency to the comment itself.
        Task { await self.notifyAuthorOfComment(postID: postID, commenterUID: uid, commenterName: author.name, text: text) }

        return CommentDTO(
            id: reference.documentID,
            authorName: author.name,
            authorHandle: author.handle,
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: author.avatarURL,
            createdAt: createdAt,
            text: text
        )
    }
}

// MARK: - Errors

enum CommentsServiceError: Error {
    case notSignedIn
}

// MARK: - Private

private extension CommentsService {
    struct Author {
        let name: String
        let handle: String
        let avatarURL: String?
    }

    func commentsCollection(postID: String) -> CollectionReference {
        firestore.collection(Constants.postsCollection).document(postID).collection(Constants.commentsCollection)
    }

    /// A missing `users/{uid}` document (anonymous guest session) is a valid state — falls back
    /// to empty name/handle and no avatar, same graceful-empty philosophy as
    /// `FeedPostSubmissionService`.
    func loadAuthor(uid: String) async throws -> Author {
        let snapshot = try await firestore.collection(Constants.usersCollection).document(uid).getDocument()
        guard snapshot.exists, let data = snapshot.data() else {
            return Author(name: "", handle: "", avatarURL: nil)
        }

        return Author(
            name: data["name"] as? String ?? "",
            handle: data["handle"] as? String ?? "",
            avatarURL: data["avatarURL"] as? String
        )
    }

    /// Best-effort denormalization of the parent post's author handle onto the new comment, for
    /// the Profile Replies tab's "Replying to @handle" UI — a failed read (or missing field) must
    /// never block the comment write, so it degrades to `nil`.
    func loadPostAuthorHandle(postID: String) async -> String? {
        guard let snapshot = try? await firestore.collection(Constants.postsCollection).document(postID).getDocument()
        else { return nil }
        return snapshot.data()?["authorHandle"] as? String
    }

    /// Best-effort — a failed notification write must never fail the comment itself, so errors
    /// are swallowed rather than thrown.
    func notifyAuthorOfComment(postID: String, commenterUID: String, commenterName: String, text: String) async {
        guard let postSnapshot = try? await firestore.collection(Constants.postsCollection).document(postID).getDocument(),
              let authorId = postSnapshot.data()?["authorId"] as? String,
              authorId != commenterUID else { return }

        try? await firestore
            .collection(Constants.usersCollection).document(authorId)
            .collection(Constants.notificationsCollection).document(UUID().uuidString)
            .setData([
                "kind": "reply",
                "actorName": commenterName,
                "quote": text,
                "createdAt": FieldValue.serverTimestamp(),
                "isUnread": true
            ])
    }

    static func map(_ document: QueryDocumentSnapshot) -> CommentDTO {
        let data = document.data()

        return CommentDTO(
            id: document.documentID,
            authorName: data["authorName"] as? String ?? "",
            authorHandle: data["authorHandle"] as? String ?? "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: data["authorAvatarURL"] as? String,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
            text: data["text"] as? String ?? ""
        )
    }
}

// MARK: - Constants

private extension CommentsService {
    enum Constants {
        static let postsCollection = "posts"
        static let commentsCollection = "comments"
        static let usersCollection = "users"
        static let notificationsCollection = "notifications"
        static let defaultAvatarImageName = "person.crop.circle.fill"
    }
}
