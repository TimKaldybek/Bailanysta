//
//  CommentsDataProvider.swift
//  Bailanysta
//

import Foundation

struct CommentsDataProvider {
    private let service: CommentsService

    init(service: CommentsService) {
        self.service = service
    }

    func loadData(postID: UUID) async throws -> [Comment] {
        let dtos = try await service.loadData(postID: postID.uuidString)
        return dtos.map(Self.map)
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
