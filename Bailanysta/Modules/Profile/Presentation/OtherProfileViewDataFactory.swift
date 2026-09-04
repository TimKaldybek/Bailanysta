//
//  OtherProfileViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct OtherProfileViewDataFactory {
    func createViewData(
        model: OtherProfileModel,
        selectedTab: ProfileTab,
        errorMessage: String? = nil
    ) -> OtherProfileViewData {
        OtherProfileViewData(
            header: Self.mapHeader(model.user),
            selectedTab: selectedTab,
            items: items(for: selectedTab, model: model).map(Self.mapPost),
            errorMessage: errorMessage
        )
    }

    private func items(for tab: ProfileTab, model: OtherProfileModel) -> [ProfilePost] {
        switch tab {
        case .posts: return model.posts
        case .likes: return model.likes
        case .replies: return model.replies
        }
    }

    private static func mapHeader(_ user: OtherProfileUser) -> OtherProfileHeaderViewData {
        OtherProfileHeaderViewData(
            avatarImageName: user.avatarImageName,
            avatarURL: user.avatarURL,
            name: user.name,
            tagline: user.tagline,
            followersCountText: groupedCount(user.followersCount),
            followingCountText: groupedCount(user.followingCount),
            postsCountText: groupedCount(user.postsCount),
            followButtonTitle: user.isFollowing ? "Search.Following".localized : "Search.Follow".localized,
            isFollowing: user.isFollowing
        )
    }

    private static func mapPost(_ post: ProfilePost) -> ProfilePostViewData {
        ProfilePostViewData(
            id: post.id,
            authorName: post.authorName,
            authorHandle: post.authorHandle,
            handleTimeText: "\(post.authorHandle) • \(timeAgoText(from: post.createdAt))",
            text: post.text,
            attachmentImageName: post.attachmentImageName,
            avatarImageName: post.avatarImageName,
            avatarURL: post.avatarURL,
            replyingToText: post.replyingToHandle,
            formattedCommentsCount: "\(post.commentsCount)",
            formattedRepostsCount: "\(post.repostsCount)",
            formattedLikesCount: "\(post.likesCount)",
            formattedViewsCount: "\(post.viewsCount)"
        )
    }

    /// Форматирует дату публикации поста в относительную строку, например "2h" — `nil` (пост без
    /// даты) сводится к пустой строке
    private static func timeAgoText(from date: Date?) -> String {
        guard let date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }

    /// Форматирует число с разрядными запятыми, например "1,248" (в отличие от сокращённого "1.2k" в своём профиле)
    private static func groupedCount(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
