//
//  FeedFilter.swift
//  Bailanysta
//

import Foundation

/// Optional server/client-side filter applied to the shared posts feed. `nil` (not this type
/// itself) means the unfiltered root Feed tab.
enum FeedFilter {
    /// Trending Searches topic — matched server-side via an exact Firestore `category` field match.
    case category(String)
    /// Free-text query from the search bar (keyword or `#hashtag`) — matched client-side against
    /// each post's `text`, since Firestore has no substring/full-text index for it.
    case keyword(String)
}
