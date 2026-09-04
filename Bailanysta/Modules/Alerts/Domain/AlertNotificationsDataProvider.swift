//
//  AlertNotificationsDataProvider.swift
//  Bailanysta
//

import Foundation

struct AlertNotificationsDataProvider {
    private let service: AlertNotificationsService

    init(service: AlertNotificationsService) {
        self.service = service
    }

    /// Wraps the Data-layer `Result<[AlertNotificationDTO], Error>` stream into the Domain-layer's
    /// `[AlertNotification]`, mirroring `FeedPostsDataProvider.observePosts()`.
    func observeNotifications() -> AsyncStream<Result<[AlertNotification], Error>> {
        AsyncStream { continuation in
            let task = Task {
                for await result in service.observeNotifications() {
                    switch result {
                    case .success(let dtos):
                        continuation.yield(.success(dtos.map(Self.map)))
                    case .failure(let error):
                        continuation.yield(.failure(error))
                    }
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    func markAllAsRead(ids: [UUID]) async throws {
        try await service.markAllAsRead(notificationIDs: ids.map(\.uuidString))
    }

    private static func map(_ dto: AlertNotificationDTO) -> AlertNotification {
        AlertNotification(
            id: UUID(uuidString: dto.id) ?? UUID(),
            kind: kind(from: dto),
            createdAt: dto.createdAt,
            isRecent: isRecent(dto.createdAt),
            isUnread: dto.isUnread
        )
    }

    private static func kind(from dto: AlertNotificationDTO) -> AlertNotificationKind {
        switch dto.kind {
        case .mention:
            return .mention(
                actorName: dto.actorName ?? "",
                contextTitle: dto.contextTitle ?? "",
                quote: dto.quote ?? ""
            )
        case .like:
            return .like(
                actorName: dto.actorName ?? "",
                othersCount: dto.othersCount ?? 0,
                postPreviewText: dto.postPreviewText ?? ""
            )
        case .invite:
            return .invite(
                workspaceName: dto.workspaceName ?? "",
                inviterName: dto.inviterName ?? ""
            )
        case .reply:
            return .reply(
                actorName: dto.actorName ?? "",
                quote: dto.quote ?? ""
            )
        }
    }

    /// "Recent" (undivided section) vs "Earlier this week" — a notification within the last day.
    private static func isRecent(_ date: Date?) -> Bool {
        guard let date else { return false }
        return Date().timeIntervalSince(date) < Constants.recentWindow
    }

    private enum Constants {
        static let recentWindow: TimeInterval = 24 * 60 * 60
    }
}
