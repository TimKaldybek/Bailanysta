//
//  FeedPostSubmissionService.swift
//  Bailanysta
//

import FirebaseFirestore
import FirebaseStorage
import Foundation

/// Writes a new post to the `posts` Firestore collection, denormalizing the author's
/// `users/{uid}` profile fields onto the document (same shape `ProfileService` reads back), and
/// uploads the first attachment image (if any) to Storage — Feed's read side only renders a
/// single `attachmentImageURL` per post.
final class FeedPostSubmissionService {
    private let firestore: Firestore
    private let storage: Storage

    init(firestore: Firestore = Firestore.firestore(), storage: Storage = Storage.storage()) {
        self.firestore = firestore
        self.storage = storage
    }

    func submit(_ dto: FeedPostSubmissionDTO) async throws {
        guard let uid = SessionManager.shared.currentUserID else {
            throw FeedPostSubmissionServiceError.notSignedIn
        }

        let author = try await loadAuthor(uid: uid)
        let postId = UUID().uuidString
        let attachmentImageURL = try await uploadAttachment(dto.attachments.first, uid: uid, postId: postId)
        let voiceMessageURL = try await uploadVoiceMessage(dto.voiceMessage, uid: uid, postId: postId)

        try await firestore.collection(Constants.postsCollection).document(postId).setData([
            "authorId": uid,
            "authorName": author.name,
            "authorHandle": author.handle,
            "authorAvatarURL": author.avatarURL as Any,
            "text": dto.text,
            "attachmentImageURL": attachmentImageURL as Any,
            "voiceMessageURL": voiceMessageURL as Any,
            "voiceMessageDuration": dto.voiceMessage?.duration as Any,
            "createdAt": FieldValue.serverTimestamp(),
            "likesCount": 0,
            "commentsCount": 0,
            "repostsCount": 0,
            "viewsCount": 0,
            "likedByUserIds": []
        ])
    }
}

// MARK: - Errors

enum FeedPostSubmissionServiceError: Error {
    case notSignedIn
}

// MARK: - Private

private extension FeedPostSubmissionService {
    struct Author {
        let name: String
        let handle: String
        let avatarURL: String?
    }

    /// A missing `users/{uid}` document (anonymous guest session) is a valid state — falls back
    /// to empty name/handle and no avatar, same graceful-empty philosophy as `ProfileService`.
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

    /// Uploads only the first attachment (Feed's read side supports a single image per post). No
    /// attachment picked results in `nil` rather than a thrown error.
    func uploadAttachment(_ attachment: FeedPostAttachmentDTO?, uid: String, postId: String) async throws -> String? {
        guard let attachment else { return nil }

        let reference = storage.reference().child("postAttachments/\(uid)/\(postId).jpg")
        try await put(attachment.imageData, to: reference)
        let url = try await reference.downloadURL()
        return url.absoluteString
    }

    /// No voice message recorded results in `nil` rather than a thrown error.
    func uploadVoiceMessage(_ voiceMessage: FeedPostVoiceMessageDTO?, uid: String, postId: String) async throws -> String? {
        guard let voiceMessage else { return nil }

        let reference = storage.reference().child("postAttachments/\(uid)/\(postId)_voice.m4a")
        try await put(voiceMessage.audioData, to: reference)
        let url = try await reference.downloadURL()
        return url.absoluteString
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
}

// MARK: - Constants

private extension FeedPostSubmissionService {
    enum Constants {
        static let usersCollection = "users"
        static let postsCollection = "posts"
    }
}
