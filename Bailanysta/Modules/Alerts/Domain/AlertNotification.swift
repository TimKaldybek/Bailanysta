//
//  AlertNotification.swift
//  Bailanysta
//

import Foundation

struct AlertNotification: Hashable {
    let id: UUID
    let kind: AlertNotificationKind
    let avatarSystemImageName: String
    let badgeSystemImageName: String?
    let timeAgoText: String
    let isRecent: Bool
    let isUnread: Bool

    func markingAsRead() -> AlertNotification {
        AlertNotification(
            id: id,
            kind: kind,
            avatarSystemImageName: avatarSystemImageName,
            badgeSystemImageName: badgeSystemImageName,
            timeAgoText: timeAgoText,
            isRecent: isRecent,
            isUnread: false
        )
    }
}

enum AlertNotificationKind: Hashable {
    case mention(actorName: String, contextTitle: String, quote: String)
    case like(actorName: String, othersCount: Int, postPreviewText: String)
    case invite(workspaceName: String, inviterName: String)
    case reply(actorName: String, quote: String)
}
