//
//  CommentDTO.swift
//  Bailanysta
//

import Foundation

struct CommentDTO {
    let id: String
    let authorName: String
    let authorHandle: String
    let avatarImageName: String
    /// Storage download URL аватара автора комментария; `nil` — используется `avatarImageName`
    let avatarURL: String?
    /// Raw creation date — formatting into a relative "time ago" string happens in the
    /// Presentation layer (`ViewDataFactory`), not here
    let createdAt: Date?
    let text: String
}
