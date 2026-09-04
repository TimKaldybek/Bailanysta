//
//  FeedInteractor.swift
//  Bailanysta
//

import Foundation

final class FeedInteractor {
    private let dataProvider: FeedPostsDataProvider
    private let likeDataProvider: FeedLikeDataProvider

    init(dataProvider: FeedPostsDataProvider, likeDataProvider: FeedLikeDataProvider) {
        self.dataProvider = dataProvider
        self.likeDataProvider = likeDataProvider
    }

    func loadData() async -> [FeedPost] {
        await dataProvider.loadData()
    }

    func toggleLike(postID: UUID) async -> FeedPost? {
        await likeDataProvider.toggleLike(postID: postID)
    }
}
