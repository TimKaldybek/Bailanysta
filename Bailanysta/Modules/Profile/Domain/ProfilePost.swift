//
//  ProfilePost.swift
//  Bailanysta
//

import Foundation

struct ProfilePost: Hashable {
    let id: UUID
    let authorName: String
    let authorHandle: String
    let avatarImageName: String
    let timeAgoText: String
    let text: String
    let attachmentImageName: String?
    let commentsCount: Int
    let repostsCount: Int
    let likesCount: Int
    let viewsCount: Int
    /// Хэндл автора исходного поста — заполнен только для вкладки Replies
    let replyingToHandle: String?
}
