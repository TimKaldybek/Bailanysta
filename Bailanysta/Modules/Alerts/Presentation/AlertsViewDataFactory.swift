//
//  AlertsViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct AlertsViewDataFactory {
    func createViewData(notifications: [AlertNotification]) -> AlertsViewData {
        AlertsViewData(
            recentNotifications: notifications.filter(\.isRecent).map(Self.map),
            earlierNotifications: notifications.filter { !$0.isRecent }.map(Self.map)
        )
    }

    private static func map(_ notification: AlertNotification) -> AlertNotificationViewData {
        AlertNotificationViewData(
            id: notification.id,
            avatarSystemImageName: avatarSystemImageName(for: notification.kind),
            badgeSystemImageName: badgeSystemImageName(for: notification.kind),
            timeAgoText: timeAgoText(from: notification.createdAt),
            message: message(for: notification.kind),
            quoteText: quoteText(for: notification.kind),
            previewText: previewText(for: notification.kind),
            captionText: captionText(for: notification.kind),
            actions: actions(for: notification.kind),
            isUnread: notification.isUnread
        )
    }

    /// `nil` (a notification without a timestamp) reduces to an empty string.
    private static func timeAgoText(from date: Date?) -> String {
        guard let date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    private static func message(for kind: AlertNotificationKind) -> AlertMessageViewData {
        switch kind {
        case .mention(let actorName, let contextTitle, _):
            return AlertMessageViewData(
                leadingText: "",
                boldText: actorName,
                trailingText: " \("Alerts.Message.Mentioned".localized) \(contextTitle)"
            )
        case .like(let actorName, let othersCount, _):
            let trailingText = othersCount > 0
                ? " " + String(format: "Alerts.Message.Liked".localized, othersCount)
                : " " + "Alerts.Message.LikedSingle".localized
            return AlertMessageViewData(leadingText: "", boldText: actorName, trailingText: trailingText)
        case .invite(let workspaceName, _):
            return AlertMessageViewData(
                leadingText: "Alerts.Message.InvitedPrefix".localized + " ",
                boldText: workspaceName,
                trailingText: " " + "Alerts.Message.InvitedSuffix".localized
            )
        case .reply(let actorName, _):
            return AlertMessageViewData(
                leadingText: "",
                boldText: actorName,
                trailingText: " " + "Alerts.Message.Replied".localized
            )
        }
    }

    private static func quoteText(for kind: AlertNotificationKind) -> String? {
        switch kind {
        case .mention(_, _, let quote): return quote
        case .reply(_, let quote): return quote
        case .like, .invite: return nil
        }
    }

    private static func previewText(for kind: AlertNotificationKind) -> String? {
        switch kind {
        case .like(_, _, let postPreviewText): return postPreviewText
        case .mention, .invite, .reply: return nil
        }
    }

    private static func captionText(for kind: AlertNotificationKind) -> String? {
        switch kind {
        case .invite(_, let inviterName):
            return String(format: "Alerts.Message.InvitedBy".localized, inviterName)
        case .mention, .like, .reply:
            return nil
        }
    }

    private static func avatarSystemImageName(for kind: AlertNotificationKind) -> String {
        switch kind {
        case .mention, .like, .reply: return "person.crop.circle.fill"
        case .invite: return "person.badge.plus"
        }
    }

    private static func badgeSystemImageName(for kind: AlertNotificationKind) -> String? {
        switch kind {
        case .mention: return "at.circle.fill"
        case .like: return "heart.circle.fill"
        case .reply: return "bubble.left.fill"
        case .invite: return nil
        }
    }

    private static func actions(for kind: AlertNotificationKind) -> AlertActionsViewData {
        switch kind {
        case .mention:
            return .single(title: "Alerts.Action.Reply".localized)
        case .invite:
            return .acceptDecline(
                acceptTitle: "Alerts.Action.Accept".localized,
                declineTitle: "Alerts.Action.Decline".localized
            )
        case .like, .reply:
            return .none
        }
    }
}
