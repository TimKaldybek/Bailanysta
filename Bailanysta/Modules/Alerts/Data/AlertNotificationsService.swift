//
//  AlertNotificationsService.swift
//  Bailanysta
//

import Foundation

final class AlertNotificationsService {
    func loadData() async -> [AlertNotificationDTO] {
        Constants.mockNotifications
    }
}

// MARK: - Constants

private extension AlertNotificationsService {
    enum Constants {
        /// Локальный источник уведомлений на время отсутствия бэкенда
        static let mockNotifications: [AlertNotificationDTO] = [
            AlertNotificationDTO(
                id: UUID().uuidString,
                kind: .mention,
                avatarSystemImageName: "person.crop.circle.fill",
                badgeSystemImageName: "at.circle.fill",
                timeAgoText: "2h ago",
                isRecent: true,
                isUnread: true,
                actorName: "Sarah Jenkins",
                contextTitle: "Q3 Design Review",
                quote: "Hey @bailanysta_user, can you take a look at the updated typography tokens here?",
                othersCount: nil,
                postPreviewText: nil,
                workspaceName: nil,
                inviterName: nil
            ),
            AlertNotificationDTO(
                id: UUID().uuidString,
                kind: .like,
                avatarSystemImageName: "person.crop.circle.fill",
                badgeSystemImageName: "heart.circle.fill",
                timeAgoText: "4h ago",
                isRecent: true,
                isUnread: true,
                actorName: "Alex Chen",
                contextTitle: nil,
                quote: nil,
                othersCount: 4,
                postPreviewText: "Just published the new fluid...",
                workspaceName: nil,
                inviterName: nil
            ),
            AlertNotificationDTO(
                id: UUID().uuidString,
                kind: .invite,
                avatarSystemImageName: "person.badge.plus",
                badgeSystemImageName: nil,
                timeAgoText: "Yesterday",
                isRecent: true,
                isUnread: true,
                actorName: nil,
                contextTitle: nil,
                quote: nil,
                othersCount: nil,
                postPreviewText: nil,
                workspaceName: "Core UI Architecture",
                inviterName: "Sarah Jenkins"
            ),
            AlertNotificationDTO(
                id: UUID().uuidString,
                kind: .reply,
                avatarSystemImageName: "cpu.fill",
                badgeSystemImageName: nil,
                timeAgoText: "Tuesday",
                isRecent: false,
                isUnread: false,
                actorName: "Design Ops Bot",
                contextTitle: nil,
                quote: "Your icon export task has completed successfully. 248 icons generated.",
                othersCount: nil,
                postPreviewText: nil,
                workspaceName: nil,
                inviterName: nil
            )
        ]
    }
}
