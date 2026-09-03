//
//  SearchItem.swift
//  Bailanysta
//

enum SearchItem: Hashable {
    case trending(TrendingTopicViewData)
    case suggestedUser(SuggestedUserViewData)
}
