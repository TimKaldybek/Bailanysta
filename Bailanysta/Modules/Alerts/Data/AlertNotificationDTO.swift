//
//  AlertNotificationDTO.swift
//  Bailanysta
//

import Foundation

struct AlertNotificationDTO {
    enum Kind: String {
        case mention
        case like
        case invite
        case reply
    }

    let id: String
    let kind: Kind
    /// Raw creation date — formatted into a relative "time ago" string by `AlertsViewDataFactory`
    let createdAt: Date?
    let isUnread: Bool

    let actorName: String?
    let contextTitle: String?
    let quote: String?
    let othersCount: Int?
    let postPreviewText: String?
    let workspaceName: String?
    let inviterName: String?
}
