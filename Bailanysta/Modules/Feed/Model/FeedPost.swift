//
//  FeedPost.swift
//  Bailanysta
//

import Foundation

struct FeedPost {
    let id: UUID
    let authorName: String
    let authorHandle: String
    let avatarImageName: String
    let timeAgoText: String
    let text: String
    let attachmentImageName: String?

    init(
        id: UUID = UUID(),
        authorName: String,
        authorHandle: String,
        avatarImageName: String = "person.crop.circle.fill",
        timeAgoText: String,
        text: String,
        attachmentImageName: String? = nil
    ) {
        self.id = id
        self.authorName = authorName
        self.authorHandle = authorHandle
        self.avatarImageName = avatarImageName
        self.timeAgoText = timeAgoText
        self.text = text
        self.attachmentImageName = attachmentImageName
    }
}
