//
//  AlertsInteractor.swift
//  Bailanysta
//

final class AlertsInteractor {
    private let dataProvider: AlertNotificationsDataProvider

    init(dataProvider: AlertNotificationsDataProvider) {
        self.dataProvider = dataProvider
    }

    func loadData() async -> [AlertNotification] {
        await dataProvider.loadData()
    }
}
