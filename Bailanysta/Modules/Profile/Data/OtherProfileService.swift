//
//  OtherProfileService.swift
//  Bailanysta
//

import Foundation

final class OtherProfileService {
    /// Мультипользовательского бэкенда пока нет — независимо от переданного `handle`
    /// возвращаются одни и те же мок-данные "Elena Rostova"
    func loadUser(handle: String) async -> OtherProfileDTO {
        Constants.mockOtherProfile
    }
}

// MARK: - Constants

private extension OtherProfileService {
    enum Constants {
        static let mockOtherProfile = OtherProfileDTO(
            user: OtherProfileUserDTO(
                id: UUID().uuidString,
                name: "Elena Rostova",
                handle: "@elena_rostova",
                tagline: "Digital Architect & UI Enthusiast. Designing for effortless precision.",
                avatarImageName: "person.crop.circle.fill",
                followersCount: 1_248,
                followingCount: 342,
                postsCount: 89,
                isFollowing: false
            ),
            posts: [
                ProfilePostDTO(
                    id: UUID().uuidString,
                    authorName: "Elena Rostova",
                    authorHandle: "@elena_rostova",
                    avatarImageName: "person.crop.circle.fill",
                    timeAgoText: "2h ago",
                    text: "Just finished migrating our design system to a token-based architecture. The shift towards tonal layering instead of heavy drop shadows makes the UI feel incredibly lightweight and airy. #DesignSystems #UIUX",
                    attachmentImageName: nil,
                    commentsCount: 18,
                    repostsCount: 0,
                    likesCount: 124,
                    viewsCount: 0,
                    replyingToHandle: nil
                ),
                ProfilePostDTO(
                    id: UUID().uuidString,
                    authorName: "Elena Rostova",
                    authorHandle: "@elena_rostova",
                    avatarImageName: "person.crop.circle.fill",
                    timeAgoText: "Yesterday",
                    text: "Loving the new workspace setup. White surfaces against natural wood really embody that modern corporate aesthetic we've been aiming for.",
                    attachmentImageName: "other_profile_post_workspace_preview",
                    commentsCount: 0,
                    repostsCount: 0,
                    likesCount: 0,
                    viewsCount: 0,
                    replyingToHandle: nil
                )
            ],
            likes: [],
            replies: []
        )
    }
}
