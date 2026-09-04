//
//  FeedComposerService.swift
//  Bailanysta
//

import FirebaseFirestore
import Foundation

/// Reads the signed-in user's `users/{uid}` document to power the compose bar's avatar/name.
/// Mirrors `ProfileService.loadData`'s read/graceful-empty pattern: no session or a missing
/// document is a valid state and returns an empty DTO instead of throwing.
final class FeedComposerService {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    /// - Throws: only on a genuine read failure (e.g. transient network error) — no session or a
    ///   missing `users/{uid}` document returns an empty DTO instead of throwing.
    func loadData() async throws -> FeedComposerDTO {
        guard let uid = SessionManager.shared.currentUserID else {
            return FeedComposerDTO(name: "", avatarURL: nil)
        }

        let snapshot = try await firestore.collection(Constants.usersCollection).document(uid).getDocument()
        guard snapshot.exists, let data = snapshot.data() else {
            return FeedComposerDTO(name: "", avatarURL: nil)
        }

        return FeedComposerDTO(
            name: data["name"] as? String ?? "",
            avatarURL: data["avatarURL"] as? String
        )
    }
}

// MARK: - Constants

private extension FeedComposerService {
    enum Constants {
        static let usersCollection = "users"
    }
}
