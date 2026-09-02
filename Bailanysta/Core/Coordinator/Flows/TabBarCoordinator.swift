//
//  TabBarCoordinator.swift
//  Bailanysta
//

import UIKit

final class TabBarCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    var onComposeTapped: (() -> Void)?

    private let feedTabCoordinator: FeedTabCoordinator
    private let searchTabCoordinator: SearchTabCoordinator
    private let alertsTabCoordinator: AlertsTabCoordinator
    private let profileTabCoordinator: ProfileTabCoordinator

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.feedTabCoordinator = FeedTabCoordinator(navigationController: UINavigationController())
        self.searchTabCoordinator = SearchTabCoordinator(navigationController: UINavigationController())
        self.alertsTabCoordinator = AlertsTabCoordinator(navigationController: UINavigationController())
        self.profileTabCoordinator = ProfileTabCoordinator(navigationController: UINavigationController())
    }

    func start() {
        feedTabCoordinator.start()
        searchTabCoordinator.start()
        alertsTabCoordinator.start()
        profileTabCoordinator.start()

        let container = TabBarContainerViewController(
            childControllers: [
                .feed: feedTabCoordinator.navigationController,
                .search: searchTabCoordinator.navigationController,
                .alerts: alertsTabCoordinator.navigationController,
                .profile: profileTabCoordinator.navigationController
            ],
            select: { _ in }
        )

        container.onComposeTapped = { [weak self] in
            self?.onComposeTapped?()
        }

        navigationController.pushViewController(container, animated: true)
    }
}
