//
//  ProfileDataProvider.swift
//  Bailanysta
//

import Foundation

struct ProfileDataProvider {
    private let service: ProfileService

    init(service: ProfileService) {
        self.service = service
    }

    func loadData() async -> ProfileModel {
        let dto = await service.loadData()
        return ProfileModel(
            user: Self.map(dto.user),
            posts: dto.posts.map(Self.map),
            replies: dto.replies.map(Self.map),
            likes: dto.likes.map(Self.map)
        )
    }

    private static func map(_ dto: ProfileUserDTO) -> ProfileUser {
        ProfileUser(
            id: UUID(uuidString: dto.id) ?? UUID(),
            name: dto.name,
            handle: dto.handle,
            roleTitle: dto.roleTitle,
            bio: dto.bio,
            avatarImageName: dto.avatarImageName,
            postsCount: dto.postsCount,
            followersCount: dto.followersCount,
            followingCount: dto.followingCount
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
