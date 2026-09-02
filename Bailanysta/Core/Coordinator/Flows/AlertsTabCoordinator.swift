//
//  AlertsTabCoordinator.swift
//  Bailanysta
//

import UIKit

final class AlertsTabCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ModuleFactory.createAlertsModule()
        navigationController.viewControllers = [vc]
    }
}
