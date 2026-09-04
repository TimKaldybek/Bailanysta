//
//  ProfileDTO.swift
//  Bailanysta
//

import Foundation

struct ProfileUserDTO {
    let id: String
    let name: String
    let handle: String
    let roleTitle: String
    let bio: String
    let avatarImageName: String
    /// Storage download URL, если пользователь загрузил аватар; `nil` — используется `avatarImageName`
    let avatarURL: String?
    let postsCount: Int
    let followersCount: Int
    let followingCount: Int
}

struct ProfilePostDTO {
    let id: String
    let authorName: String
    let authorHandle: String
    let avatarImageName: String
    /// Storage download URL аватара автора; `nil` — используется `avatarImageName`
    let avatarURL: String?
    /// Raw creation date — formatting into a relative "time ago" string happens in the
    /// Presentation layer (`ViewDataFactory`), not here
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

struct ProfileDTO {
    let user: ProfileUserDTO
    let posts: [ProfilePostDTO]
    let replies: [ProfilePostDTO]
    let likes: [ProfilePostDTO]
}

/// Данные для загрузки нового аватара — картинка уже сконвертирована в JPEG на уровне `DataProvider`
struct ProfileAvatarUploadDTO {
    let imageData: Data
}
