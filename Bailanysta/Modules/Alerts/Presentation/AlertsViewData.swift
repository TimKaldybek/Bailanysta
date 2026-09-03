//
//  AlertsViewData.swift
//  Bailanysta
//

import Foundation

struct AlertsViewData {
    let recentNotifications: [AlertNotificationViewData]
    let earlierNotifications: [AlertNotificationViewData]
}

struct AlertNotificationViewData: Hashable {
    let id: UUID
    let avatarSystemImageName: String
    let badgeSystemImageName: String?
    let timeAgoText: String
    let message: AlertMessageViewData
    /// Цитата в карточке-блоке (упоминание/ответ бота)
    let quoteText: String?
    /// Превью поста с иконкой (лайк)
    let previewText: String?
    /// Обычная подпись без оформления (кем отправлено приглашение)
    let captionText: String?
    let actions: AlertActionsViewData
    let isUnread: Bool
}

/// Заголовок карточки, собранный из обычного + выделенного жирным фрагмента текста
struct AlertMessageViewData: Hashable {
    let leadingText: String
    let boldText: String
    let trailingText: String
}

enum AlertActionsViewData: Hashable {
    case none
    case single(title: String)
    case acceptDecline(acceptTitle: String, declineTitle: String)
}
