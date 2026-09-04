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

    func loadData(handle: String) async throws -> OtherProfileModel {
        let dto = try await service.loadUser(handle: handle)
        return OtherProfileModel(
            user: Self.map(dto.user),
            posts: dto.posts.map(Self.map),
            likes: dto.likes.map(Self.map),
            replies: dto.replies.map(Self.map)
        )
    }

    /// Delegates to the `Service` and passes the resulting new `isFollowing` state straight
    /// through — nothing to map, this is an action, not a DTO read.
    func toggleFollow(targetUid: String, isFollowing: Bool) async throws -> Bool {
        try await service.toggleFollow(targetUid: targetUid, isFollowing: isFollowing)
    }

    private static func map(_ dto: OtherProfileUserDTO) -> OtherProfileUser {
        OtherProfileUser(
            uid: dto.id,
            name: dto.name,
            handle: dto.handle,
            tagline: dto.tagline,
            avatarImageName: dto.avatarImageName,
            avatarURL: dto.avatarURL.flatMap(URL.init(string:)),
            followersCount: dto.followersCount,
            followingCount: dto.followingCount,
            postsCount: dto.postsCount,
            isFollowing: dto.isFollowing
        )
    }

    private static func map(_ dto: ProfilePostDTO) -> ProfilePost {
        ProfilePost(
            id: dto.id,
            authorName: dto.authorName,
            authorHandle: dto.authorHandle,
            avatarImageName: dto.avatarImageName,
            avatarURL: dto.avatarURL.flatMap(URL.init(string:)),
            createdAt: dto.createdAt,
            text: dto.text,
            attachmentImageName: dto.attachmentImageName,
            commentsCount: dto.commentsCount,
            repostsCount: dto.repostsCount,
            likesCount: dto.likesCount,
            viewsCount: dto.viewsCount,
            replyingToHandle: dto.replyingToHandle,
            parentPostId: dto.parentPostId
        )
    }
}
