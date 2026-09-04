//
//  ProfileViewData.swift
//  Bailanysta
//

import Foundation

struct ProfileViewData {
    let header: ProfileHeaderViewData
    let selectedTab: ProfileTab
    let items: [ProfilePostViewData]
}

struct ProfileHeaderViewData: Hashable {
    let avatarImageName: String
    let name: String
    let handle: String
    /// Готовая для отображения строка "@handle • Role"
    let handleAndRole: String
    let bio: String
    let postsCountText: String
    let followersCountText: String
    let followingCountText: String
}

/// Данные для ячейки карточки профиля: сама карточка + выбранная вкладка (Posts/Replies/Likes)
struct ProfileHeaderCellViewData: Hashable {
    let header: ProfileHeaderViewData
    let selectedTab: ProfileTab
}

struct ProfilePostViewData: Hashable {
    let id: UUID
    let authorName: String
    /// Готовая для отображения строка "@handle • time"
    let handleTimeText: String
    let text: String
    let attachmentImageName: String?
    let avatarImageName: String
    /// "Replying to @handle" — заполнено только для вкладки Replies
    let replyingToText: String?
    let formattedCommentsCount: String
    let formattedRepostsCount: String
    let formattedLikesCount: String
    let formattedViewsCount: String
}
