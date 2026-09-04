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
    /// Storage download URL аватара автора комментария; `nil` — используется `avatarImageName`
    let avatarURL: URL?
    /// Raw creation date — formatted into a relative "time ago" string by `CommentsViewDataFactory`
    let createdAt: Date?
    let text: String
}
