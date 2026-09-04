//
//  FeedPostDTO.swift
//  Bailanysta
//

import Foundation

struct FeedPostDTO {
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
    /// Firestore `attachmentImageURL` — `nil` means the post has no attachment
    let attachmentImageURL: String?
    let likesCount: Int
    let isLiked: Bool
    let commentsCount: Int
}
