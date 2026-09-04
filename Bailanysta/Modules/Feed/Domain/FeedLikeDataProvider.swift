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

    func toggleLike(postID: UUID, isLiked: Bool) async throws -> FeedPost {
        let dto = try await service.toggleLike(postID: postID.uuidString, isLiked: isLiked)
        return Self.map(dto)
    }

    private static func map(_ dto: FeedPostDTO) -> FeedPost {
        FeedPost(
            id: UUID(uuidString: dto.id) ?? UUID(),
            authorName: dto.authorName,
            authorHandle: dto.authorHandle,
            avatarImageName: dto.avatarImageName,
            avatarURL: dto.avatarURL.flatMap(URL.init(string:)),
            createdAt: dto.createdAt,
            text: dto.text,
            attachmentImageName: dto.attachmentImageName,
            attachmentImageURL: dto.attachmentImageURL.flatMap(URL.init(string:)),
            voiceMessageURL: dto.voiceMessageURL.flatMap(URL.init(string:)),
            voiceMessageDuration: dto.voiceMessageDuration,
            likesCount: dto.likesCount,
            isLiked: dto.isLiked,
            commentsCount: dto.commentsCount
        )
    }
}
