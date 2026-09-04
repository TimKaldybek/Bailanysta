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
    /// Storage download URL аватара автора; `nil` — используется `avatarImageName`
    let avatarURL: URL?
    /// Raw creation date — formatted into a relative "time ago" string by `ViewDataFactory`
    let createdAt: Date?
    let text: String
    let attachmentImageName: String?
    let commentsCount: Int
    let repostsCount: Int
    let likesCount: Int
    let viewsCount: Int
    /// Хэндл автора исходного поста — заполнен только для вкладки Replies
    let replyingToHandle: String?
}
