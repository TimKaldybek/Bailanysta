//
//  FeedPostsService.swift
//  Bailanysta
//

import Foundation

final class FeedPostsService {
    func loadData() async -> [FeedPostDTO] {
        Constants.mockPosts
    }
}

// MARK: - Constants

private extension FeedPostsService {
    enum Constants {
        /// Локальный источник постов на время отсутствия бэкенда
        static let mockPosts: [FeedPostDTO] = [
            FeedPostDTO(
                id: UUID().uuidString,
                authorName: "Alex Rivera",
                authorHandle: "@arivera",
                avatarImageName: "person.crop.circle.fill",
                timeAgoText: "2h",
                text: "Just wrapped up the new design system overview. The emphasis on spatial typography and tonal elevation is really changing how we approach UI architecture. Loving the 'Indigo Light' direction! 🚀",
                attachmentImageName: "feed_post_design_system_preview",
                likesCount: 245,
                commentsCount: 42
            )
        ]
    }
}
