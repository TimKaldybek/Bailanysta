//
//  CommentsViewData.swift
//  Bailanysta
//

import Foundation

struct CommentsViewData {
    let comments: [CommentViewData]
    let isEmpty: Bool
}

struct CommentViewData: Hashable {
    let id: UUID
    let authorName: String
    let handleTimeText: String
    let avatarImageName: String
    let text: String
}
