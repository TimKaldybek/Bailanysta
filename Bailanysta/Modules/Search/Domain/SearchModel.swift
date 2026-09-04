//
//  SearchModel.swift
//  Bailanysta
//

import Foundation

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
    let imageURL: URL?
}

struct SuggestedUser {
    let id: String
    let name: String
    let handle: String
    let avatarImageName: String
    let avatarURL: URL?
    var isFollowing: Bool
}
