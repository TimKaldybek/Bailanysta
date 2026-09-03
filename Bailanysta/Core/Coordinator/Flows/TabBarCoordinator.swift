//
//  TabBarCoordinator.swift
//  Bailanysta
//

import UIKit

final class TabBarCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    var onComposeTapped: (() -> Void)?

    private let tabCoordinators: [TabBarItem: Coordinator]

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.tabCoordinators = [
            .feed: CoordinatorFactory.feedTabCoordinator(navigationController: UINavigationController()),
            .search: CoordinatorFactory.searchTabCoordinator(navigationController: UINavigationController()),
            .alerts: CoordinatorFactory.alertsTabCoordinator(navigationController: UINavigationController()),
            .profile: CoordinatorFactory.profileTabCoordinator(navigationController: UINavigationController())
        ]
    }

    func start() {
        tabCoordinators.values.forEach { $0.start() }

        let container = TabBarContainerViewController(
            childControllers: tabCoordinators.mapValues(\.navigationController)
        )

        container.onComposeTapped = { [weak self] in
            self?.onComposeTapped?()
        }

        navigationController.pushViewController(container, animated: true)
    }
}
