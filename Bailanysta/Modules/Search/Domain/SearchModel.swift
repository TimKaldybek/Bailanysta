//
//  SearchModel.swift
//  Bailanysta
//

struct SearchModel {
    var trendingTopics: [TrendingTopic]
    var suggestedUsers: [SuggestedUser]
}

struct TrendingTopic {
    let id: String
    let rank: Int
    let category: String
    let title: String
    let subtitle: String
}

struct SuggestedUser {
    let id: String
    let name: String
    let handle: String
    let avatarImageName: String
    var isFollowing: Bool
}
