//
//  FeedLikeService.swift
//  Bailanysta
//

import Foundation

final class FeedLikeService {
    func toggleLike(postID: String) async -> FeedPostDTO? {
        guard let record = await MockBackendService.shared.toggleLike(postID: postID) else { return nil }
        return Self.map(record)
    }

    private static func map(_ record: MockBackendService.BackendPost) -> FeedPostDTO {
        FeedPostDTO(
            id: record.id,
            authorName: record.authorName,
            authorHandle: record.authorHandle,
            avatarImageName: record.avatarImageName,
            timeAgoText: record.timeAgoText,
            text: record.text,
            attachmentImageName: record.attachmentImageName,
            likesCount: record.likesCount,
            isLiked: record.isLiked,
            commentsCount: record.commentsCount
        )
    }
}
