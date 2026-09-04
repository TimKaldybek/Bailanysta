//
//  FeedViewData.swift
//  Bailanysta
//

import Foundation

struct FeedViewData {
    /// Ready-made cell list — either shimmering placeholders or real posts, already resolved by
    /// `FeedViewDataFactory` so `FeedDataSource` only has to apply it, never decide between them.
    let items: [FeedItem]
    let composer: FeedComposerViewData
    /// One-off failure message (e.g. load/like failed) — `nil` when there's nothing to show
    let errorMessage: String?
}

/// Signed-in user's identity, rendered by the compose bar's avatar.
struct FeedComposerViewData {
    let avatarImageName: String
    let avatarURL: URL?
}

struct FeedPostViewData: Hashable {
    let id: UUID
    let authorName: String
    let authorHandle: String
    /// Готовая для отображения строка "@handle • time", например "@arivera • 2h"
    let handleTimeText: String
    let text: String
    let attachmentImageURL: URL?
    let avatarImageName: String
    let avatarURL: URL?
    let formattedLikesCount: String
    let formattedCommentsCount: String
    let isLiked: Bool
}
