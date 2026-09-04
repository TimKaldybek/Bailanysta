//
//  ProfileTabCoordinator.swift
//  Bailanysta
//

import UIKit

final class ProfileTabCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    private var settingsCoordinator: SettingsCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ModuleFactory.createProfileModule()

        vc.settingsButtonTapped = { [weak self] in
            self?.showSettings()
        }
        vc.shareTapped = { [weak self] handle in
            self?.presentShareSheet(handle: handle, from: vc)
        }

        navigationController.viewControllers = [vc]
    }

    private func showSettings() {
        let coordinator = CoordinatorFactory.settingsCoordinator(navigationController: navigationController)

        settingsCoordinator = coordinator

        coordinator.start()
    }

    private func presentShareSheet(handle: String, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [handle], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
    }
}
