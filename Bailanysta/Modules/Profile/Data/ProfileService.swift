//
//  ProfileService.swift
//  Bailanysta
//

import Foundation

final class ProfileService {
    func loadData() async -> ProfileDTO {
        Constants.mockProfile
    }
}

// MARK: - Constants

private extension ProfileService {
    enum Constants {
        /// Локальный источник данных профиля на время отсутствия бэкенда
        static let mockProfile = ProfileDTO(user: mockUser, posts: mockPosts, replies: mockReplies, likes: mockLikes)

        static let mockUser = ProfileUserDTO(
            id: UUID().uuidString,
            name: "Alex Chen",
            handle: "@alexc_designs",
            roleTitle: "Digital Creator",
            bio: "Exploring the intersection of modern minimalism and interactive design. Always looking for the next creative spark. ✨",
            avatarImageName: "person.crop.circle.fill",
            postsCount: 142,
            followersCount: 8400,
            followingCount: 642
        )

        static let mockPosts: [ProfilePostDTO] = [
            ProfilePostDTO(
                id: UUID().uuidString,
                authorName: "Alex Chen",
                authorHandle: "@alexc_designs",
                avatarImageName: "person.crop.circle.fill",
                timeAgoText: "Just now",
                text: "Just deployed the new visual token system for our upcoming platform refresh. The transition from heavy shadows to subtle tonal layering is making everything feel so much lighter and faster. What do you think of this aesthetic? 🎨✨",
                attachmentImageName: "profile_post_token_system_preview",
                commentsCount: 0,
                repostsCount: 0,
                likesCount: 0,
                viewsCount: 12,
                replyingToHandle: nil
            ),
            ProfilePostDTO(
                id: UUID().uuidString,
                authorName: "Alex Chen",
                authorHandle: "@alexc_designs",
                avatarImageName: "person.crop.circle.fill",
                timeAgoText: "2h",
                text: "Whitespace is not empty space; it is structural material.",
                attachmentImageName: nil,
                commentsCount: 3,
                repostsCount: 1,
                likesCount: 24,
                viewsCount: 156,
                replyingToHandle: nil
            )
        ]

        static let mockReplies: [ProfilePostDTO] = [
            ProfilePostDTO(
                id: UUID().uuidString,
                authorName: "Alex Chen",
                authorHandle: "@alexc_designs",
                avatarImageName: "person.crop.circle.fill",
                timeAgoText: "45m",
                text: "Totally agree — tonal layering also reads better in dark mode since you're not fighting harsh shadow contrast.",
                attachmentImageName: nil,
                commentsCount: 1,
                repostsCount: 0,
                likesCount: 8,
                viewsCount: 64,
                replyingToHandle: "@marina.codes"
            ),
            ProfilePostDTO(
                id: UUID().uuidString,
                authorName: "Alex Chen",
                authorHandle: "@alexc_designs",
                avatarImageName: "person.crop.circle.fill",
                timeAgoText: "5h",
                text: "Figma variables + Swift enums, one source of truth. Happy to share the token pipeline if you're curious.",
                attachmentImageName: nil,
                commentsCount: 2,
                repostsCount: 0,
                likesCount: 15,
                viewsCount: 98,
                replyingToHandle: "@devon.builds"
            )
        ]

        static let mockLikes: [ProfilePostDTO] = [
            ProfilePostDTO(
                id: UUID().uuidString,
                authorName: "Marina Lopez",
                authorHandle: "@marina.codes",
                avatarImageName: "person.crop.circle.fill",
                timeAgoText: "1h",
                text: "Shipped dark mode across the whole design system today. Every token now flips automatically — no more one-off overrides. 🌙",
                attachmentImageName: nil,
                commentsCount: 6,
                repostsCount: 2,
                likesCount: 132,
                viewsCount: 940,
                replyingToHandle: nil
            ),
            ProfilePostDTO(
                id: UUID().uuidString,
                authorName: "Devon Park",
                authorHandle: "@devon.builds",
                avatarImageName: "person.crop.circle.fill",
                timeAgoText: "1d",
                text: "Compositional layout + diffable data sources is the combo I wish I'd learned years ago. Everything else feels like fighting the framework.",
                attachmentImageName: nil,
                commentsCount: 4,
                repostsCount: 1,
                likesCount: 87,
                viewsCount: 512,
                replyingToHandle: nil
            )
        ]
    }
}
