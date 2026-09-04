//
//  ProfileViewData.swift
//  Bailanysta
//

import Foundation

struct ProfileViewData {
    let header: ProfileHeaderViewData
    let selectedTab: ProfileTab
    let items: [ProfilePostViewData]
    /// Placeholder shown instead of the list when `items` is empty (tab-specific, e.g. "No posts yet.")
    let emptyStateMessage: String
    /// One-off failure message (e.g. avatar upload failed) — `nil` when there's nothing to show
    let errorMessage: String?
}

struct ProfileHeaderViewData: Hashable {
    let avatarImageName: String
    let avatarURL: URL?
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
    let id: String
    let authorName: String
    let authorHandle: String
    /// Готовая для отображения строка "@handle • time"
    let handleTimeText: String
    let text: String
    let attachmentImageName: String?
    let avatarImageName: String
    let avatarURL: URL?
    /// "Replying to @handle" — заполнено только для вкладки Replies
    let replyingToText: String?
    let formattedCommentsCount: String
    let formattedRepostsCount: String
    let formattedLikesCount: String
    let formattedViewsCount: String
    /// Id родительского поста — заполнен только для вкладки Replies (`nil` для Posts/Likes)
    let parentPostId: String?
    /// `true` для Posts/Replies (свой контент), `false` для Likes (чужой пост)
    let canDelete: Bool
    /// Id поста, чей экран комментариев открывать по тапу — это сам пост для Posts/Likes,
    /// либо `parentPostId` для Replies (тап должен вести к посту, а не к самому комментарию)
    let commentsTargetId: String
}
