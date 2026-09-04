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

        vc.suggestedUserTapped = { [weak self] handle in
            self?.showOtherProfile(handle: handle)
        }

        navigationController.viewControllers = [vc]
    }

    private func showOtherProfile(handle: String) {
        let vc = ModuleFactory.createOtherProfileModule(handle: handle)

        vc.backButtonTapped = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }

        navigationController.pushViewController(vc, animated: true)
    }
}
