//
//  FeedPost.swift
//  Bailanysta
//

import Foundation

struct FeedPost: Hashable {
    let id: UUID
    let authorName: String
    let authorHandle: String
    let avatarImageName: String
    /// Storage download URL аватара автора; `nil` — используется `avatarImageName`
    let avatarURL: URL?
    /// Raw creation date — formatted into a relative "time ago" string by `FeedViewDataFactory`
    let createdAt: Date?
    let text: String
    let attachmentImageName: String?
    let attachmentImageURL: URL?
    let voiceMessageURL: URL?
    let voiceMessageDuration: TimeInterval?
    let likesCount: Int
    let isLiked: Bool
    let commentsCount: Int
}
