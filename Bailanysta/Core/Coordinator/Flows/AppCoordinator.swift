//
//  MainCoordinator.swift
//  Bailanysta
//
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?
    let navigationController: UINavigationController
    
    private var coordinators = [Coordinator]()
    private var signOutObserver: NSObjectProtocol?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        signOutObserver = NotificationCenter.default.addObserver(
            forName: .userDidSignOut,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSignedOut()
        }
    }

    deinit {
        if let signOutObserver {
            NotificationCenter.default.removeObserver(signOutObserver)
        }
    }

    func start() {
        if SessionManager.shared.isSignedIn {
            showMainFlow()
        } else {
            showAuthFlow()
        }
    }

    private func handleSignedOut() {
        coordinators.removeAll()
        navigationController.setViewControllers([], animated: false)
        start()
    }

    private func showAuthFlow() {
        let coordinator = CoordinatorFactory.authCoordinator(navigationController: navigationController)
        coordinators.append(coordinator)

        coordinator.completionHandler = { [weak self] in
            self?.coordinators.removeAll(where: { $0 === coordinator })
            // Drop the auth screens from the stack so the main flow becomes the new root.
            self?.navigationController.setViewControllers([], animated: false)
            self?.showMainFlow()
        }

        coordinator.start()
    }

    private func showMainFlow() {
        let coordinator = CoordinatorFactory.mainCoordinator(navigationController: navigationController)
        coordinators.append(coordinator)

        coordinator.completionHandler = { [weak self] in
            self?.coordinators.removeAll(where: { $0 === coordinator })
            self?.completionHandler?()
        }

        coordinator.start()
    }
}
