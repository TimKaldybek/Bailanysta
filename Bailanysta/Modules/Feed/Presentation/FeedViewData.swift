//
//  FeedViewData.swift
//  Bailanysta
//

import Foundation

struct FeedViewData {
    let posts: [FeedPostViewData]
}

struct FeedPostViewData: Hashable {
    let id: UUID
    let authorName: String
    let authorHandle: String
    /// Готовая для отображения строка "@handle • time", например "@arivera • 2h"
    let handleTimeText: String
    let text: String
    let attachmentImageName: String?
    let avatarImageName: String
    let formattedLikesCount: String
    let formattedCommentsCount: String
    let isLiked: Bool
}
