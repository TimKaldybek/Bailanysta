//
//  FeedPostsDataProvider.swift
//  Bailanysta
//

import Foundation

struct FeedPostsDataProvider {
    private let service: FeedPostsService

    init(service: FeedPostsService) {
        self.service = service
    }

    func loadData() async -> [FeedPost] {
        let dtos = await service.loadData()
        return dtos.map(Self.map)
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
