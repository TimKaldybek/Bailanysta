//
//  ProfileViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct ProfileViewDataFactory {
    func createViewData(model: ProfileModel, selectedTab: ProfileTab) -> ProfileViewData {
        ProfileViewData(
            header: Self.mapHeader(model.user),
            selectedTab: selectedTab,
            items: items(for: selectedTab, model: model).map(Self.mapPost)
        )
    }

    private func items(for tab: ProfileTab, model: ProfileModel) -> [ProfilePost] {
        switch tab {
        case .posts: return model.posts
        case .replies: return model.replies
        case .likes: return model.likes
        }
    }

    private static func mapHeader(_ user: ProfileUser) -> ProfileHeaderViewData {
        ProfileHeaderViewData(
            avatarImageName: user.avatarImageName,
            name: user.name,
            handle: user.handle,
            handleAndRole: "\(user.handle) • \(user.roleTitle)",
            bio: user.bio,
            postsCountText: "\(user.postsCount)",
            followersCountText: shortCount(user.followersCount),
            followingCountText: shortCount(user.followingCount)
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

    /// 0-999 — как есть, дальше сокращается до "1.2k" / "3.4m" (строчная буква, как в макете)
    private static func shortCount(_ value: Int) -> String {
        switch value {
        case 0..<1_000:
            return "\(value)"
        case 1_000..<1_000_000:
            return String(format: "%.1fk", Double(value) / 1_000)
        default:
            return String(format: "%.1fm", Double(value) / 1_000_000)
        }
    }
}
