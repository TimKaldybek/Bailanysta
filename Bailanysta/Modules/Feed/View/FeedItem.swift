//
//  FeedItem.swift
//  Bailanysta
//

enum FeedItem: Hashable {
    case post(FeedPostViewData)
    /// Placeholder card shown while the first page of posts is loading; the associated value only
    /// keeps skeleton slots unique in the diffable snapshot.
    case skeleton(Int)
}
