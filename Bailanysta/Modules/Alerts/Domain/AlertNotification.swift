//
//  AlertNotification.swift
//  Bailanysta
//

import Foundation

struct AlertNotification: Hashable {
    let id: UUID
    let kind: AlertNotificationKind
    let createdAt: Date?
    let isRecent: Bool
    let isUnread: Bool

    func markingAsRead() -> AlertNotification {
        AlertNotification(id: id, kind: kind, createdAt: createdAt, isRecent: isRecent, isUnread: false)
    }
}

enum AlertNotificationKind: Hashable {
    case mention(actorName: String, contextTitle: String, quote: String)
    case like(actorName: String, othersCount: Int, postPreviewText: String)
    case invite(workspaceName: String, inviterName: String)
    case reply(actorName: String, quote: String)
}
