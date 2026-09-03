//
//  AlertsPresenter.swift
//  Bailanysta
//

import Foundation

final class AlertsPresenter {
    weak var view: AlertsViewInput?

    private let interactor: AlertsInteractor
    private let viewDataFactory: AlertsViewDataFactory

    private var notifications: [AlertNotification] = []

    init(interactor: AlertsInteractor, viewDataFactory: AlertsViewDataFactory) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    func load() {
        Task { @MainActor in
            notifications = await interactor.loadData()
            pushViewData()
        }
    }

    func markAllAsRead() {
        notifications = notifications.map { $0.markingAsRead() }
        pushViewData()
    }

    func reply(to id: UUID) {
        notifications = notifications.map { $0.id == id ? $0.markingAsRead() : $0 }
        pushViewData()
    }

    func acceptInvite(id: UUID) {
        notifications.removeAll { $0.id == id }
        pushViewData()
    }

    func declineInvite(id: UUID) {
        notifications.removeAll { $0.id == id }
        pushViewData()
    }
}

// MARK: - Private

private extension AlertsPresenter {
    func pushViewData() {
        let viewData = viewDataFactory.createViewData(notifications: notifications)
        view?.display(viewData)
    }
}
