//
//  FeedTabCoordinator.swift
//  Bailanysta
//

import UIKit

final class FeedTabCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    private var settingsCoordinator: SettingsCoordinator?
    private var feedPostCoordinator: FeedPostCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ModuleFactory.createFeedModule()

        vc.settingsButtonTapped = { [weak self] in
            self?.showSettings()
        }
        vc.composeButtonTapped = { [weak self] in
            self?.presentCreatePost()
        }

        navigationController.viewControllers = [vc]
    }

    private func showSettings() {
        let coordinator = CoordinatorFactory.settingsCoordinator(navigationController: navigationController)

        settingsCoordinator = coordinator

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
