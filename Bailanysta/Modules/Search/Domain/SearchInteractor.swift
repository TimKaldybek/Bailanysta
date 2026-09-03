//
//  SearchInteractor.swift
//  Bailanysta
//

final class SearchInteractor {
    private let dataProvider: SearchLandingDataProvider

    init(dataProvider: SearchLandingDataProvider) {
        self.dataProvider = dataProvider
    }

    func loadData() async -> SearchModel {
        await dataProvider.loadData()
    }
}
