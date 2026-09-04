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

    /// Guards against starting a second live listener — mirrors `FeedPresenter.observeTask`.
    private var observeTask: Task<Void, Never>?

    init(interactor: AlertsInteractor, viewDataFactory: AlertsViewDataFactory) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    /// Starts the notifications' live Firestore listener exactly once. Safe to call more than
    /// once — a second call is a no-op while the listener is already live.
    func load() {
        guard observeTask == nil else { return }
        observeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await result in interactor.observeNotifications() {
                switch result {
                case .success(let notifications):
                    self.notifications = notifications
                    pushViewData()
                case .failure:
                    // A genuine read failure is a no-op against `notifications` — keep the
                    // last-known-good list on screen instead of wiping it.
                    break
                }
            }
        }
    }

    /// Optimistically marks every unread notification read locally, then persists it — a failed
    /// write is a no-op against the optimistic UI (the live listener will reconcile on its own).
    func markAllAsRead() {
        let unreadIDs = notifications.filter(\.isUnread).map(\.id)
        guard !unreadIDs.isEmpty else { return }

        notifications = notifications.map { $0.markingAsRead() }
        pushViewData()

        Task {
            try? await interactor.markAllAsRead(ids: unreadIDs)
        }
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
