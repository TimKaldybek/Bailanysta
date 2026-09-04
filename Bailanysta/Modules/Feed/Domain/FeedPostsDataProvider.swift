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

    func loadData(filter: FeedFilter? = nil) async throws -> [FeedPost] {
        let dtos = try await service.loadData(filter: filter)
        return dtos.map { $0.toFeedPost() }
    }

    func observePosts(filter: FeedFilter? = nil) -> AsyncStream<Result<[FeedPost], Error>> {
        AsyncStream { continuation in
            let task = Task {
                for await result in service.observePosts(filter: filter) {
                    switch result {
                    case .success(let dtos):
                        continuation.yield(.success(dtos.map { $0.toFeedPost() }))
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
}
