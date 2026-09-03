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

    func loadData() async -> [AlertNotification] {
        let dtos = await service.loadData()
        return dtos.map(Self.map)
    }

    private static func map(_ dto: AlertNotificationDTO) -> AlertNotification {
        AlertNotification(
            id: UUID(uuidString: dto.id) ?? UUID(),
            kind: kind(from: dto),
            avatarSystemImageName: dto.avatarSystemImageName,
            badgeSystemImageName: dto.badgeSystemImageName,
            timeAgoText: dto.timeAgoText,
            isRecent: dto.isRecent,
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
}
