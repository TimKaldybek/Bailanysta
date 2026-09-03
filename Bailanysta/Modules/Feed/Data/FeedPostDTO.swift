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
    let timeAgoText: String
    let text: String
    let attachmentImageName: String?
    let likesCount: Int
    let commentsCount: Int
}
