//
//  AddCommentDataProvider.swift
//  Bailanysta
//

import Foundation

struct AddCommentDataProvider {
    private let service: CommentsService

    init(service: CommentsService) {
        self.service = service
    }

    func addComment(postID: UUID, text: String) async -> Comment? {
        guard let dto = await service.addComment(postID: postID.uuidString, text: text) else { return nil }
        return Self.map(dto)
    }

    private static func map(_ dto: CommentDTO) -> Comment {
        Comment(
            id: UUID(uuidString: dto.id) ?? UUID(),
            authorName: dto.authorName,
            authorHandle: dto.authorHandle,
            avatarImageName: dto.avatarImageName,
            timeAgoText: dto.timeAgoText,
            text: dto.text
        )
    }
}
