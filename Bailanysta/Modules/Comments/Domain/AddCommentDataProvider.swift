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

    func addComment(postID: UUID, text: String) async throws -> Comment {
        let dto = try await service.addComment(postID: postID.uuidString, text: text)
        return Self.map(dto)
    }

    private static func map(_ dto: CommentDTO) -> Comment {
        Comment(
            id: UUID(uuidString: dto.id) ?? UUID(),
            authorName: dto.authorName,
            authorHandle: dto.authorHandle,
            avatarImageName: dto.avatarImageName,
            avatarURL: dto.avatarURL.flatMap(URL.init(string:)),
            createdAt: dto.createdAt,
            text: dto.text
        )
    }
}
