//
//  ProfileTabCoordinator.swift
//  Bailanysta
//

import UIKit

final class ProfileTabCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    private var settingsCoordinator: SettingsCoordinator?
    private var commentsCoordinator: CommentsCoordinator?

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
        vc.postAuthorTapped = { [weak self] handle in
            self?.showOtherProfile(handle: handle)
        }
        vc.commentsTapped = { [weak self] postID in
            self?.showComments(postID: postID)
        }

        navigationController.viewControllers = [vc]
    }

    private func showComments(postID: UUID) {
        let coordinator = CoordinatorFactory.commentsCoordinator(navigationController: navigationController, postID: postID)
        commentsCoordinator = coordinator
        coordinator.start()
    }

    private func showOtherProfile(handle: String) {
        let vc = ModuleFactory.createOtherProfileModule(handle: handle)

        vc.backButtonTapped = { [weak self] in
            self?.navigationController.popViewController(animated: true)
        }
        vc.settingsButtonTapped = { [weak self] in
            self?.showSettings()
        }

        navigationController.pushViewController(vc, animated: true)
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
