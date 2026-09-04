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
        return dto.toFeedPost()
    }
}
