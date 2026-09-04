//
//  OtherProfileViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct OtherProfileViewDataFactory {
    func createViewData(
        model: OtherProfileModel,
        selectedTab: ProfileTab,
        isLoading: Bool,
        errorMessage: String? = nil
    ) -> OtherProfileViewData {
        OtherProfileViewData(
            header: Self.mapHeader(model.user),
            selectedTab: selectedTab,
            items: Self.items(for: selectedTab, model: model, isLoading: isLoading),
            isLoading: isLoading,
            errorMessage: errorMessage
        )
    }

    private static func items(for tab: ProfileTab, model: OtherProfileModel, isLoading: Bool) -> [OtherProfileItem] {
        let posts = rawItems(for: tab, model: model)
        guard isLoading && posts.isEmpty else {
            return posts.map { .post(mapPost($0)) }
        }
        return (0..<Constants.skeletonCount).map { .skeleton($0) }
    }

    private static func rawItems(for tab: ProfileTab, model: OtherProfileModel) -> [ProfilePost] {
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
            formattedViewsCount: "\(post.viewsCount)",
            parentPostId: post.parentPostId,
            // На чужом профиле удаление недоступно — можно удалять только свой контент
            canDelete: false,
            commentsTargetId: post.parentPostId ?? post.id
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

    private enum Constants {
        static let skeletonCount = 3
    }
}
