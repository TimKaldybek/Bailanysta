//
//  OtherProfileDataProvider.swift
//  Bailanysta
//

import Foundation

struct OtherProfileDataProvider {
    private let service: OtherProfileService

    init(service: OtherProfileService) {
        self.service = service
    }

    func loadData(handle: String) async -> OtherProfileModel {
        let dto = await service.loadUser(handle: handle)
        return OtherProfileModel(
            user: Self.map(dto.user),
            posts: dto.posts.map(Self.map),
            likes: dto.likes.map(Self.map),
            replies: dto.replies.map(Self.map)
        )
    }

    private static func map(_ dto: OtherProfileUserDTO) -> OtherProfileUser {
        OtherProfileUser(
            id: UUID(uuidString: dto.id) ?? UUID(),
            name: dto.name,
            handle: dto.handle,
            tagline: dto.tagline,
            avatarImageName: dto.avatarImageName,
            followersCount: dto.followersCount,
            followingCount: dto.followingCount,
            postsCount: dto.postsCount,
            isFollowing: dto.isFollowing
        )
    }

    private static func map(_ dto: ProfilePostDTO) -> ProfilePost {
        ProfilePost(
            id: UUID(uuidString: dto.id) ?? UUID(),
            authorName: dto.authorName,
            authorHandle: dto.authorHandle,
            avatarImageName: dto.avatarImageName,
            timeAgoText: dto.timeAgoText,
            text: dto.text,
            attachmentImageName: dto.attachmentImageName,
            commentsCount: dto.commentsCount,
            repostsCount: dto.repostsCount,
            likesCount: dto.likesCount,
            viewsCount: dto.viewsCount,
            replyingToHandle: dto.replyingToHandle
        )
    }
}
