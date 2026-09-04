//
//  CommentsService.swift
//  Bailanysta
//

import Foundation

final class CommentsService {
    func loadData(postID: String) async -> [CommentDTO] {
        await MockBackendService.shared.fetchComments(postID: postID).map(Self.map)
    }

    func addComment(postID: String, text: String) async -> CommentDTO? {
        guard let record = await MockBackendService.shared.addComment(postID: postID, text: text) else { return nil }
        return Self.map(record)
    }

    private static func map(_ record: MockBackendService.BackendComment) -> CommentDTO {
        CommentDTO(
            id: record.id,
            authorName: record.authorName,
            authorHandle: record.authorHandle,
            avatarImageName: record.avatarImageName,
            timeAgoText: record.timeAgoText,
            text: record.text
        )
    }
}
