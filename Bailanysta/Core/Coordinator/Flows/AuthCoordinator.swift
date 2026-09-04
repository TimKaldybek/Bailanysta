//
//  AuthCoordinator.swift
//  Bailanysta
//

import UIKit

final class AuthCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ModuleFactory.createLoginModule()

        vc.onAuthenticated = { [weak self] in
            self?.completionHandler?()
        }
        vc.onSignUpTapped = { [weak self] in
            self?.showSignUp()
        }

        navigationController.viewControllers = [vc]
    }

    private func showSignUp() {
        let vc = ModuleFactory.createSignUpModule()

        vc.onAuthenticated = { [weak self] in
            self?.completionHandler?()
        }

        navigationController.pushViewController(vc, animated: true)
    }
}
