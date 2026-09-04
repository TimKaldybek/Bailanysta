//
//  FeedPostsDataProvider.swift
//  Bailanysta
//

import Foundation

struct FeedPostsDataProvider {
    private let service: FeedPostsService

    init(service: FeedPostsService) {
        self.service = service
    }

    func loadData() async throws -> [FeedPost] {
        let dtos = try await service.loadData()
        return dtos.map(Self.map)
    }
    
    func observePosts() -> AsyncStream<Result<[FeedPost], Error>> {
        AsyncStream { continuation in
            let task = Task {
                for await result in service.observePosts() {
                    switch result {
                    case .success(let dtos):
                        continuation.yield(.success(dtos.map(Self.map)))
                    case .failure(let error):
                        continuation.yield(.failure(error))
                    }
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    private static func map(_ dto: FeedPostDTO) -> FeedPost {
        FeedPost(
            id: UUID(uuidString: dto.id) ?? UUID(),
            authorName: dto.authorName,
            authorHandle: dto.authorHandle,
            avatarImageName: dto.avatarImageName,
            avatarURL: dto.avatarURL.flatMap(URL.init(string:)),
            createdAt: dto.createdAt,
            text: dto.text,
            attachmentImageName: dto.attachmentImageName,
            attachmentImageURL: dto.attachmentImageURL.flatMap(URL.init(string:)),
            voiceMessageURL: dto.voiceMessageURL.flatMap(URL.init(string:)),
            voiceMessageDuration: dto.voiceMessageDuration,
            likesCount: dto.likesCount,
            isLiked: dto.isLiked,
            commentsCount: dto.commentsCount
        )
    }
}
