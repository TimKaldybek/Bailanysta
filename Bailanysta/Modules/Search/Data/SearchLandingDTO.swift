//
//  SearchLandingDTO.swift
//  Bailanysta
//

struct SearchLandingDTO {
    let trendingTopics: [TrendingTopicDTO]
    let suggestedUsers: [SuggestedUserDTO]
}

struct TrendingTopicDTO {
    let id: String
    let rank: Int
    let category: String
    let title: String
    let subtitle: String
}

struct SuggestedUserDTO {
    let id: String
    let name: String
    let handle: String
    let avatarImageName: String
}
