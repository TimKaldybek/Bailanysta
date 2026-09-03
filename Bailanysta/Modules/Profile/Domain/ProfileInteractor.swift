//
//  ProfileInteractor.swift
//  Bailanysta
//

final class ProfileInteractor {
    private let dataProvider: ProfileDataProvider

    init(dataProvider: ProfileDataProvider) {
        self.dataProvider = dataProvider
    }

    func loadData() async -> ProfileModel {
        await dataProvider.loadData()
    }
}
