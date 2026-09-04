//
//  OtherProfileInteractor.swift
//  Bailanysta
//

final class OtherProfileInteractor {
    private let dataProvider: OtherProfileDataProvider

    init(dataProvider: OtherProfileDataProvider) {
        self.dataProvider = dataProvider
    }

    func loadData(handle: String) async throws -> OtherProfileModel {
        try await dataProvider.loadData(handle: handle)
    }
}
