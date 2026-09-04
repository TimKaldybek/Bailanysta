//
//  FeedViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct FeedViewDataFactory {
    func createViewData(
        posts: [FeedPost],
        composer: FeedComposer,
        isLoading: Bool,
        errorMessage: String? = nil
    ) -> FeedViewData {
        FeedViewData(
            items: Self.items(posts: posts, isLoading: isLoading),
            composer: Self.map(composer),
            errorMessage: errorMessage
        )
    }

    /// Shimmering placeholders while the first page is loading and nothing has arrived yet;
    /// real posts otherwise.
    private static func items(posts: [FeedPost], isLoading: Bool) -> [FeedItem] {
        guard isLoading && posts.isEmpty else {
            return posts.map { .post(map($0)) }
        }
        return (0..<Constants.skeletonCount).map { .skeleton($0) }
    }

    private static func map(_ post: FeedPost) -> FeedPostViewData {
        FeedPostViewData(
            id: post.id,
            authorName: post.authorName,
            authorHandle: post.authorHandle,
            handleTimeText: "\(post.authorHandle) • \(timeAgoText(from: post.createdAt))",
            text: post.text,
            attachmentImageURL: post.attachmentImageURL,
            voiceMessage: post.voiceMessageURL.map {
                FeedVoiceMessageViewData(url: $0, duration: post.voiceMessageDuration ?? 0)
            },
            avatarImageName: post.avatarImageName,
            avatarURL: post.avatarURL,
            formattedLikesCount: formattedCount(post.likesCount),
            formattedCommentsCount: formattedCount(post.commentsCount),
            isLiked: post.isLiked
        )
    }

    private static func map(_ composer: FeedComposer) -> FeedComposerViewData {
        FeedComposerViewData(avatarImageName: composer.avatarImageName, avatarURL: composer.avatarURL)
    }

    /// Форматирует дату публикации поста в относительную строку, например "2h" — `nil` (пост без
    /// даты) сводится к пустой строке
    private static func timeAgoText(from date: Date?) -> String {
        guard let date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
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

    private enum Constants {
        static let skeletonCount = 4
    }
}
