//
//  CommentsViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct CommentsViewDataFactory {
    func createViewData(comments: [Comment]) -> CommentsViewData {
        CommentsViewData(comments: comments.map(Self.map), isEmpty: comments.isEmpty)
    }

    private static func map(_ comment: Comment) -> CommentViewData {
        CommentViewData(
            id: comment.id,
            authorName: comment.authorName,
            handleTimeText: "\(comment.authorHandle) • \(comment.timeAgoText)",
            avatarImageName: comment.avatarImageName,
            text: comment.text
        )
    }
}
