//
//  CommentsViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct CommentsViewDataFactory {
    func createViewData(comments: [Comment], errorMessage: String? = nil) -> CommentsViewData {
        CommentsViewData(comments: comments.map(Self.map), isEmpty: comments.isEmpty, errorMessage: errorMessage)
    }

    private static func map(_ comment: Comment) -> CommentViewData {
        CommentViewData(
            id: comment.id,
            authorName: comment.authorName,
            handleTimeText: "\(comment.authorHandle) • \(timeAgoText(from: comment.createdAt))",
            avatarImageName: comment.avatarImageName,
            avatarURL: comment.avatarURL,
            text: comment.text
        )
    }

    /// Форматирует дату публикации комментария в относительную строку, например "2h" — `nil`
    /// (комментарий без даты) сводится к пустой строке
    private static func timeAgoText(from date: Date?) -> String {
        guard let date else { return "" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
