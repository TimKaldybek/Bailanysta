//
//  SearchViewData.swift
//  Bailanysta
//

import Foundation

struct SearchViewData {
    let recentSearches: [RecentSearchViewData]
    let trendingTopics: [TrendingTopicViewData]
    let suggestedUsers: [SuggestedUserViewData]
    /// One-off failure message (e.g. load failed) — `nil` when there's nothing to show
    let errorMessage: String?
}

struct RecentSearchViewData: Hashable {
    let id: String
    let text: String
}

struct TrendingTopicViewData: Hashable {
    let id: String
    /// Готовая для отображения строка метаданных, например "1 • Technology • Trending"
    let metaText: String
    let title: String
    let subtitle: String
    let imageURL: URL?
}

struct SuggestedUserViewData: Hashable {
    let id: String
    let name: String
    let handle: String
    let avatarImageName: String
    let avatarURL: URL?
    let followButtonTitle: String
    let isFollowing: Bool
}
