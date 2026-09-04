//
//  Comment.swift
//  Bailanysta
//

import Foundation

struct Comment: Hashable {
    let id: UUID
    let authorName: String
    let authorHandle: String
    let avatarImageName: String
    let timeAgoText: String
    let text: String
}
