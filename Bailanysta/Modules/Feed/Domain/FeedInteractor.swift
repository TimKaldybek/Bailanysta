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

    func loadData() async throws -> [FeedPost] {
        try await dataProvider.loadData()
    }

    func observePosts() -> AsyncStream<Result<[FeedPost], Error>> {
        dataProvider.observePosts()
    }

    func toggleLike(postID: UUID, isLiked: Bool) async throws -> FeedPost {
        try await likeDataProvider.toggleLike(postID: postID, isLiked: isLiked)
    }

    func loadComposer() async throws -> FeedComposer {
        try await composerDataProvider.loadData()
    }
}
