//
//  OtherProfileViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct OtherProfileViewDataFactory {
    func createViewData(model: OtherProfileModel, selectedTab: ProfileTab) -> OtherProfileViewData {
        OtherProfileViewData(
            header: Self.mapHeader(model.user),
            selectedTab: selectedTab,
            items: items(for: selectedTab, model: model).map(Self.mapPost)
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
            handleTimeText: "\(post.authorHandle) • \(post.timeAgoText)",
            text: post.text,
            attachmentImageName: post.attachmentImageName,
            avatarImageName: post.avatarImageName,
            formattedCommentsCount: "\(post.commentsCount)",
            formattedRepostsCount: "\(post.repostsCount)",
            formattedLikesCount: "\(post.likesCount)",
            formattedViewsCount: "\(post.viewsCount)"
        )
    }

    /// Форматирует число с разрядными запятыми, например "1,248" (в отличие от сокращённого "1.2k" в своём профиле)
    private static func groupedCount(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.usesGroupingSeparator = true
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }
}
