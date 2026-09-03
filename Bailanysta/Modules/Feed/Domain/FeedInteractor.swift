//
//  FeedInteractor.swift
//  Bailanysta
//

final class FeedInteractor {
    private let dataProvider: FeedPostsDataProvider

    init(dataProvider: FeedPostsDataProvider) {
        self.dataProvider = dataProvider
    }

    func loadData() async -> [FeedPost] {
        await dataProvider.loadData()
    }
}
