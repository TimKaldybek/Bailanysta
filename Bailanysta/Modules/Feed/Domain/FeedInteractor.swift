//
//  FeedInteractor.swift
//  Bailanysta
//

import Foundation

final class FeedInteractor {
    private let dataProvider: FeedPostsDataProvider
    private let likeDataProvider: FeedLikeDataProvider
    private let composerDataProvider: FeedComposerDataProvider

    init(
        dataProvider: FeedPostsDataProvider,
        likeDataProvider: FeedLikeDataProvider,
        composerDataProvider: FeedComposerDataProvider
    ) {
        self.dataProvider = dataProvider
        self.likeDataProvider = likeDataProvider
        self.composerDataProvider = composerDataProvider
    }

    func loadData(filter: FeedFilter? = nil) async throws -> [FeedPost] {
        try await dataProvider.loadData(filter: filter)
    }

    func observePosts(filter: FeedFilter? = nil) -> AsyncStream<Result<[FeedPost], Error>> {
        dataProvider.observePosts(filter: filter)
    }

    func toggleLike(postID: UUID, isLiked: Bool) async throws -> FeedPost {
        try await likeDataProvider.toggleLike(postID: postID, isLiked: isLiked)
    }

    func loadComposer() async throws -> FeedComposer {
        try await composerDataProvider.loadData()
    }
}
