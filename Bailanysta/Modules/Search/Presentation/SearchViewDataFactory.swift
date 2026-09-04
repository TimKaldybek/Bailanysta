//
//  SearchViewDataFactory.swift
//  Bailanysta
//

struct SearchViewDataFactory {
    func createViewData(model: SearchModel, recentSearches: [String], errorMessage: String? = nil) -> SearchViewData {
        SearchViewData(
            recentSearches: recentSearches.enumerated().map { index, text in
                RecentSearchViewData(id: "\(index)-\(text)", text: text)
            },
            trendingTopics: model.trendingTopics.map(Self.map),
            suggestedUsers: model.suggestedUsers.map(Self.map),
            errorMessage: errorMessage
        )
    }

    private static func map(_ topic: TrendingTopic) -> TrendingTopicViewData {
        TrendingTopicViewData(
            id: topic.id,
            metaText: "\(topic.rank) • \(topic.category) • \("Search.Trending".localized)",
            title: topic.title,
            subtitle: topic.subtitle,
            imageURL: topic.imageURL
        )
    }

    private static func map(_ user: SuggestedUser) -> SuggestedUserViewData {
        SuggestedUserViewData(
            id: user.id,
            name: user.name,
            handle: user.handle,
            avatarImageName: user.avatarImageName,
            avatarURL: user.avatarURL,
            followButtonTitle: user.isFollowing ? "Search.Following".localized : "Search.Follow".localized,
            isFollowing: user.isFollowing
        )
    }
}
