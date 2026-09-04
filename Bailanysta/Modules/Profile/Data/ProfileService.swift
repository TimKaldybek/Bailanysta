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

        return ProfileDTO(user: user, posts: posts, replies: [], likes: [])
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
}

// MARK: - Errors

enum ProfileServiceError: Error {
    case notSignedIn
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
            followersCount: 0,
            followingCount: 0
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

private extension ProfileService {
    enum Constants {
        static let usersCollection = "users"
        static let postsCollection = "posts"
        static let defaultAvatarImageName = "person.crop.circle.fill"
    }
}
