//
//  SearchTabCoordinator.swift
//  Bailanysta
//

import UIKit

final class SearchTabCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ModuleFactory.createSearchModule()
        navigationController.viewControllers = [vc]
    }
}
