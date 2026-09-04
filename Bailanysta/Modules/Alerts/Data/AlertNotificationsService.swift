//
//  AlertNotificationsService.swift
//  Bailanysta
//

import FirebaseFirestore
import Foundation

/// Reads/writes the current user's `users/{uid}/notifications` subcollection. Notification
/// documents themselves are written by whichever module triggers them (`FeedLikeService` on a
/// like, `CommentsService` on a comment) — this Service only ever touches the signed-in user's
/// own notifications.
final class AlertNotificationsService {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    /// Live-updating notifications list. No session (signed out) yields an empty list once rather
    /// than opening a listener with no owner.
    func observeNotifications() -> AsyncStream<Result<[AlertNotificationDTO], Error>> {
        AsyncStream { continuation in
            guard let uid = SessionManager.shared.currentUserID else {
                continuation.yield(.success([]))
                continuation.finish()
                return
            }

            let registration = notificationsCollection(uid: uid)
                .order(by: "createdAt", descending: true)
                .addSnapshotListener { snapshot, error in
                    if let error {
                        continuation.yield(.failure(error))
                        return
                    }
                    guard let snapshot else { return }
                    continuation.yield(.success(snapshot.documents.compactMap(Self.map)))
                }

            continuation.onTermination = { _ in
                registration.remove()
            }
        }
    }

    /// Batches all updates into one write so marking a whole page of notifications read is atomic.
    func markAllAsRead(notificationIDs: [String]) async throws {
        guard let uid = SessionManager.shared.currentUserID, !notificationIDs.isEmpty else { return }

        let collection = notificationsCollection(uid: uid)
        let batch = firestore.batch()
        notificationIDs.forEach { batch.updateData(["isUnread": false], forDocument: collection.document($0)) }
        try await batch.commit()
    }
}

// MARK: - Private

private extension AlertNotificationsService {
    func notificationsCollection(uid: String) -> CollectionReference {
        firestore.collection(Constants.usersCollection).document(uid).collection(Constants.notificationsCollection)
    }

    /// An unrecognized/missing `kind` is dropped rather than mapped to a placeholder — a
    /// notification this client can't render is not a valid empty state to show.
    static func map(_ document: QueryDocumentSnapshot) -> AlertNotificationDTO? {
        let data = document.data()
        guard let kindRaw = data["kind"] as? String, let kind = AlertNotificationDTO.Kind(rawValue: kindRaw) else {
            return nil
        }

        return AlertNotificationDTO(
            id: document.documentID,
            kind: kind,
            createdAt: (data["createdAt"] as? Timestamp)?.dateValue(),
            isUnread: data["isUnread"] as? Bool ?? true,
            actorName: data["actorName"] as? String,
            contextTitle: data["contextTitle"] as? String,
            quote: data["quote"] as? String,
            othersCount: data["othersCount"] as? Int,
            postPreviewText: data["postPreviewText"] as? String,
            workspaceName: data["workspaceName"] as? String,
            inviterName: data["inviterName"] as? String
        )
    }
}

// MARK: - Constants

private extension AlertNotificationsService {
    enum Constants {
        static let usersCollection = "users"
        static let notificationsCollection = "notifications"
    }
}
