//
//  ProfileTabCoordinator.swift
//  Bailanysta
//

import UIKit

final class ProfileTabCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ModuleFactory.createProfileModule()
        navigationController.viewControllers = [vc]
    }
}
