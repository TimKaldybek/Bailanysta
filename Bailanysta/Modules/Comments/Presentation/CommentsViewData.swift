//
//  CommentsViewData.swift
//  Bailanysta
//

import Foundation

struct CommentsViewData {
    let comments: [CommentViewData]
    let isEmpty: Bool
    /// One-off failure message (e.g. load/send failed) — `nil` when there's nothing to show
    let errorMessage: String?
}

struct CommentViewData: Hashable {
    let id: UUID
    let authorName: String
    let handleTimeText: String
    let avatarImageName: String
    let avatarURL: URL?
    let text: String
}
