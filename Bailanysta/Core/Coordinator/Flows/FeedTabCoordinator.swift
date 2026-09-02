//
//  FeedTabCoordinator.swift
//  Bailanysta
//

import UIKit

final class FeedTabCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ModuleFactory.createFeedModule()
        navigationController.viewControllers = [vc]
    }
}
