//
//  FeedPostsService.swift
//  Bailanysta
//

import Foundation

final class FeedPostsService {
    func loadData() async -> [FeedPostDTO] {
        await MockBackendService.shared.fetchPosts().map(Self.map)
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
