//
//  FeedViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct FeedViewDataFactory {
    func createViewData(posts: [FeedPost]) -> FeedViewData {
        FeedViewData(posts: posts.map(Self.map))
    }

    private static func map(_ post: FeedPost) -> FeedPostViewData {
        FeedPostViewData(
            id: post.id,
            authorName: post.authorName,
            authorHandle: post.authorHandle,
            handleTimeText: "\(post.authorHandle) • \(post.timeAgoText)",
            text: post.text,
            attachmentImageName: post.attachmentImageName,
            avatarImageName: post.avatarImageName,
            formattedLikesCount: formattedCount(post.likesCount),
            formattedCommentsCount: formattedCount(post.commentsCount),
            isLiked: post.isLiked
        )
    }

    /// 0-999 — как есть, дальше сокращается до "1.2K" / "3.4M"
    private static func formattedCount(_ value: Int) -> String {
        switch value {
        case 0..<1_000:
            return "\(value)"
        case 1_000..<1_000_000:
            return String(format: "%.1fK", Double(value) / 1_000)
        default:
            return String(format: "%.1fM", Double(value) / 1_000_000)
        }
    }
}
