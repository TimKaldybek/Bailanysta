//
//  ProfileService.swift
//  Bailanysta
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

/// Reads the signed-in user's `users/{uid}` document and their `posts` from Firestore, and
/// uploads a new avatar image to Storage. An anonymous "Continue as Guest" session (a valid
/// `SessionManager.shared.currentUserID`, but no `users/{uid}` document written on sign-up) is a
/// real, non-error state — it's mapped to an empty/default profile rather than treated as a failure.
final class ProfileService {
    private let firestore: Firestore
    private let storage: Storage

    init(firestore: Firestore = Firestore.firestore(), storage: Storage = Storage.storage()) {
        self.firestore = firestore
        self.storage = storage
    }

    /// - Throws: only on a genuine read failure (e.g. transient network error) — a missing
    ///   `users/{uid}` document (anonymous guest session) is a valid state and returns an
    ///   empty-profile DTO instead of throwing.
    func loadData() async throws -> ProfileDTO {
        guard let uid = SessionManager.shared.currentUserID else {
            return ProfileDTO(user: Self.emptyUser(id: ""), posts: [], replies: [], likes: [])
        }

        let posts = try await loadPosts(authorId: uid)
        let user = try await loadUser(uid: uid, postsCount: posts.count)
        let replies = await loadReplies(uid: uid)
        let likes = await loadLikedPosts(uid: uid)

        return ProfileDTO(user: user, posts: posts, replies: replies, likes: likes)
    }

    func uploadAvatar(_ dto: ProfileAvatarUploadDTO) async throws -> URL {
        guard let uid = SessionManager.shared.currentUserID else {
            throw ProfileServiceError.notSignedIn
        }

        let reference = storage.reference().child("avatars/\(uid).jpg")
        try await put(dto.imageData, to: reference)
        let url = try await reference.downloadURL()

        try await firestore.collection(Constants.usersCollection).document(uid)
            .setData(["avatarURL": url.absoluteString], merge: true)

        return url
    }

    /// Deletes the post document, all of its comments (Firestore doesn't cascade-delete
    /// subcollections), and best-effort cleans up its Storage attachments.
    ///
    /// - Throws: `ProfileServiceError.notOwner` if the post isn't the signed-in user's own — the
    ///   UI only ever surfaces delete for the current user's own Posts/Replies tabs, but this is
    ///   checked here too as defense-in-depth since Firestore's security rules don't enforce it.
    func deletePost(postID: String) async throws {
        guard let uid = SessionManager.shared.currentUserID else {
            throw ProfileServiceError.notSignedIn
        }

        let postReference = firestore.collection(Constants.postsCollection).document(postID)
        let postSnapshot = try await postReference.getDocument()
        guard postSnapshot.exists, postSnapshot.data()?["authorId"] as? String == uid else {
            throw ProfileServiceError.notOwner
        }

        let commentsSnapshot = try await postReference.collection(Constants.commentsCollectionGroup).getDocuments()

        let batch = firestore.batch()
        for commentDocument in commentsSnapshot.documents {
            batch.deleteDocument(commentDocument.reference)
        }
        batch.deleteDocument(postReference)
        try await batch.commit()

        try? await storage.reference().child("postAttachments/\(uid)/\(postID).jpg").delete()
        try? await storage.reference().child("postAttachments/\(uid)/\(postID)_voice.m4a").delete()
    }

    /// Deletes a single reply and best-effort decrements the parent post's `commentsCount` — a
    /// failed decrement (e.g. the post was already deleted) shouldn't make the delete look failed.
    ///
    /// - Throws: `ProfileServiceError.notOwner` if the comment isn't the signed-in user's own —
    ///   same defense-in-depth reasoning as `deletePost`.
    func deleteReply(postID: String, commentID: String) async throws {
        guard let uid = SessionManager.shared.currentUserID else {
            throw ProfileServiceError.notSignedIn
        }

        let commentReference = firestore.collection(Constants.postsCollection).document(postID)
            .collection(Constants.commentsCollectionGroup).document(commentID)
        let commentSnapshot = try await commentReference.getDocument()
        guard commentSnapshot.exists, commentSnapshot.data()?["authorId"] as? String == uid else {
            throw ProfileServiceError.notOwner
        }

        try await commentReference.delete()

        try? await firestore.collection(Constants.postsCollection).document(postID).updateData([
            "commentsCount": FieldValue.increment(Int64(-1))
        ])
    }
}

// MARK: - Errors

enum ProfileServiceError: Error {
    case notSignedIn
    case notOwner
}

// MARK: - Private

private extension ProfileService {
    /// A missing document is a valid empty state (`return`), a Firestore read error is a genuine
    /// failure and propagates (`throw`) so the caller can keep its last-known-good data.
    func loadUser(uid: String, postsCount: Int) async throws -> ProfileUserDTO {
        let snapshot = try await firestore.collection(Constants.usersCollection).document(uid).getDocument()
        guard snapshot.exists, let data = snapshot.data() else {
            return Self.emptyUser(id: uid)
        }
        return Self.mapUser(id: uid, data: data, postsCount: postsCount)
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

    /// Оборачивает closure-based `StorageReference.putData` в `async throws`, т.к. используемая
    /// версия FirebaseStorage не предоставляет async-перегрузку для загрузки данных
    func put(_ data: Data, to reference: StorageReference) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            reference.putData(data, metadata: nil) { _, error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }

    static func emptyUser(id: String) -> ProfileUserDTO {
        ProfileUserDTO(
            id: id,
            name: "",
            handle: "",
            roleTitle: "",
            bio: "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: nil,
            postsCount: 0,
            followersCount: 0,
            followingCount: 0
        )
    }

    static func mapUser(id: String, data: [String: Any], postsCount: Int) -> ProfileUserDTO {
        ProfileUserDTO(
            id: id,
            name: data["name"] as? String ?? "",
            handle: data["handle"] as? String ?? "",
            roleTitle: "",
            bio: "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: data["avatarURL"] as? String,
            postsCount: postsCount,
            followersCount: data["followersCount"] as? Int ?? 0,
            followingCount: data["followingCount"] as? Int ?? 0
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

private extension ProfileService {
    enum Constants {
        static let usersCollection = "users"
        static let postsCollection = "posts"
        static let commentsCollectionGroup = "comments"
        static let defaultAvatarImageName = "person.crop.circle.fill"
    }
}
