//
//  ProfileViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct ProfileViewDataFactory {
    func createViewData(model: ProfileModel, selectedTab: ProfileTab, errorMessage: String? = nil) -> ProfileViewData {
        ProfileViewData(
            header: Self.mapHeader(model.user),
            selectedTab: selectedTab,
            items: items(for: selectedTab, model: model).map { Self.mapPost($0, selectedTab: selectedTab) },
            emptyStateMessage: Self.emptyStateMessage(for: selectedTab),
            errorMessage: errorMessage
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
            avatarURL: user.avatarURL,
            name: user.name,
            handle: user.handle,
            handleAndRole: user.roleTitle.isEmpty ? user.handle : "\(user.handle) • \(user.roleTitle)",
            bio: user.bio.isEmpty ? "Profile.Placeholder.Bio".localized : user.bio,
            postsCountText: "\(user.postsCount)",
            followersCountText: shortCount(user.followersCount),
            followingCountText: shortCount(user.followingCount)
        )
    }

    /// Пока настоящих Replies/Likes-коллекций нет — короткое "пусто" сообщение под каждый таб
    private static func emptyStateMessage(for tab: ProfileTab) -> String {
        switch tab {
        case .posts: return "Profile.Empty.Posts".localized
        case .replies: return "Profile.Empty.Replies".localized
        case .likes: return "Profile.Empty.Likes".localized
        }
    }

    private static func mapPost(_ post: ProfilePost, selectedTab: ProfileTab) -> ProfilePostViewData {
        ProfilePostViewData(
            id: post.id,
            authorName: post.authorName,
            authorHandle: post.authorHandle,
            handleTimeText: "\(post.authorHandle) • \(timeAgoText(from: post.createdAt))",
            text: post.text,
            attachmentImageName: post.attachmentImageName,
            avatarImageName: post.avatarImageName,
            avatarURL: post.avatarURL,
            replyingToText: post.replyingToHandle.map { String(format: "Profile.ReplyingTo".localized, $0) },
            formattedCommentsCount: "\(post.commentsCount)",
            formattedRepostsCount: "\(post.repostsCount)",
            formattedLikesCount: "\(post.likesCount)",
            formattedViewsCount: "\(post.viewsCount)",
            parentPostId: post.parentPostId,
            canDelete: selectedTab != .likes,
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
