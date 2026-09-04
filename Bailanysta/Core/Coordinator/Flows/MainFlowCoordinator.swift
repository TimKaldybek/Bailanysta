//
//  MainFlowCoordinator.swift
//  Bailanysta
//
//

import UIKit

final class MainFlowCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?
    let navigationController: UINavigationController
    private var tabBarCoordinator: TabBarCoordinator?
    private var feedPostCoordinator: FeedPostCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showTabBarFlow()
    }

    private func showTabBarFlow() {
        let coordinator = CoordinatorFactory.tabBarCoordinator(navigationController: navigationController)

        tabBarCoordinator = coordinator

        coordinator.onComposeTapped = { [weak self] in
            self?.presentCreatePost()
        }

        coordinator.start()
    }

    private func presentCreatePost() {
        let coordinator = CoordinatorFactory.feedPostCoordinator(navigationController: navigationController)
        feedPostCoordinator = coordinator
        coordinator.completionHandler = { [weak self] in
            self?.feedPostCoordinator = nil
        }
        coordinator.start()
    }
}
