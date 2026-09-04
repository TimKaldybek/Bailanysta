//
//  AlertsInteractor.swift
//  Bailanysta
//

import Foundation

final class AlertsInteractor {
    private let dataProvider: AlertNotificationsDataProvider

    init(dataProvider: AlertNotificationsDataProvider) {
        self.dataProvider = dataProvider
    }

    /// Live-updating notifications — stays open for the module's lifetime, see `AlertsPresenter.load()`.
    func observeNotifications() -> AsyncStream<Result<[AlertNotification], Error>> {
        dataProvider.observeNotifications()
    }

    func markAllAsRead(ids: [UUID]) async throws {
        try await dataProvider.markAllAsRead(ids: ids)
    }
}
