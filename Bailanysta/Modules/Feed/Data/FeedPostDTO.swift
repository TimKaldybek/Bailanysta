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
    /// Firestore Storage download URL of a recorded voice message — `nil` means no voice message
    let voiceMessageURL: String?
    let voiceMessageDuration: TimeInterval?
    let likesCount: Int
    let isLiked: Bool
    let commentsCount: Int
}

extension FeedPostDTO {
    /// Shared by every `Domain` layer caller that maps this DTO to `FeedPost`
    /// (`FeedPostsDataProvider`, `FeedLikeDataProvider`) so the mapping stays in one place.
    func toFeedPost() -> FeedPost {
        FeedPost(
            id: UUID(uuidString: id) ?? UUID(),
            authorName: authorName,
            authorHandle: authorHandle,
            avatarImageName: avatarImageName,
            avatarURL: avatarURL.flatMap(URL.init(string:)),
            createdAt: createdAt,
            text: text,
            attachmentImageName: attachmentImageName,
            attachmentImageURL: attachmentImageURL.flatMap(URL.init(string:)),
            voiceMessageURL: voiceMessageURL.flatMap(URL.init(string:)),
            voiceMessageDuration: voiceMessageDuration,
            likesCount: likesCount,
            isLiked: isLiked,
            commentsCount: commentsCount
        )
    }
}
