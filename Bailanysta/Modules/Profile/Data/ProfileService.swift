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
        static let mockProfile = ProfileDTO(
            user: ProfileUserDTO(
                id: UUID().uuidString,
                name: "Alex Chen",
                handle: "@alexc_designs",
                roleTitle: "Digital Creator",
                bio: "Exploring the intersection of modern minimalism and interactive design. Always looking for the next creative spark. ✨",
                avatarImageName: "person.crop.circle.fill",
                postsCount: 142,
                followersCount: 8400,
                followingCount: 642
            ),
            posts: [
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
                    viewsCount: 12
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
                    viewsCount: 156
                )
            ],
            replies: [],
            likes: []
        )
    }
}
