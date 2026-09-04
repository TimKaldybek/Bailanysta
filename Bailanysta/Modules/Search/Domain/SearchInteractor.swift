//
//  SearchInteractor.swift
//  Bailanysta
//

final class SearchInteractor {
    private let dataProvider: SearchLandingDataProvider

    init(dataProvider: SearchLandingDataProvider) {
        self.dataProvider = dataProvider
    }

    func loadData() async throws -> SearchModel {
        try await dataProvider.loadData()
    }
}
