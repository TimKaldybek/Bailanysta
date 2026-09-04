//
//  FeedLikeDataProvider.swift
//  Bailanysta
//

import Foundation

struct FeedLikeDataProvider {
    private let service: FeedLikeService

    init(service: FeedLikeService) {
        self.service = service
    }

    func toggleLike(postID: UUID) async -> FeedPost? {
        guard let dto = await service.toggleLike(postID: postID.uuidString) else { return nil }
        return Self.map(dto)
    }

    private static func map(_ dto: FeedPostDTO) -> FeedPost {
        FeedPost(
            id: UUID(uuidString: dto.id) ?? UUID(),
            authorName: dto.authorName,
            authorHandle: dto.authorHandle,
            avatarImageName: dto.avatarImageName,
            timeAgoText: dto.timeAgoText,
            text: dto.text,
            attachmentImageName: dto.attachmentImageName,
            likesCount: dto.likesCount,
            isLiked: dto.isLiked,
            commentsCount: dto.commentsCount
        )
    }
}
