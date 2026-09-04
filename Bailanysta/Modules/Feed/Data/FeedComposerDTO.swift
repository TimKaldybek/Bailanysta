//
//  FeedComposerDTO.swift
//  Bailanysta
//

import Foundation

struct FeedComposerDTO {
    let name: String
    /// Storage download URL аватара текущего пользователя; `nil` — используется дефолтная иконка
    let avatarURL: String?
}
