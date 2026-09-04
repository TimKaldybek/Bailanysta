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

    func loadData() async throws -> ProfileModel {
        let dto = try await service.loadData()
        return ProfileModel(
            user: Self.map(dto.user),
            posts: dto.posts.map(Self.map),
            replies: dto.replies.map(Self.map),
            likes: dto.likes.map(Self.map)
        )
    }

    func uploadAvatar(imageData: Data) async throws {
        _ = try await service.uploadAvatar(ProfileAvatarUploadDTO(imageData: imageData))
    }

    func deletePost(postID: String) async throws {
        try await service.deletePost(postID: postID)
    }

    func deleteReply(postID: String, commentID: String) async throws {
        try await service.deleteReply(postID: postID, commentID: commentID)
    }

    private static func map(_ dto: ProfileUserDTO) -> ProfileUser {
        ProfileUser(
            id: UUID(uuidString: dto.id) ?? UUID(),
            name: dto.name,
            handle: dto.handle,
            roleTitle: dto.roleTitle,
            bio: dto.bio,
            avatarImageName: dto.avatarImageName,
            avatarURL: dto.avatarURL.flatMap(URL.init(string:)),
            postsCount: dto.postsCount,
            followersCount: dto.followersCount,
            followingCount: dto.followingCount
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
