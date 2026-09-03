//
//  AlertNotificationDTO.swift
//  Bailanysta
//

import Foundation

struct AlertNotificationDTO {
    enum Kind {
        case mention
        case like
        case invite
        case reply
    }

    let id: String
    let kind: Kind
    let avatarSystemImageName: String
    let badgeSystemImageName: String?
    let timeAgoText: String
    let isRecent: Bool
    let isUnread: Bool

    let actorName: String?
    let contextTitle: String?
    let quote: String?
    let othersCount: Int?
    let postPreviewText: String?
    let workspaceName: String?
    let inviterName: String?
}
