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
    private var commentsCoordinator: CommentsCoordinator?

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
        vc.postAuthorTapped = { [weak self] handle in
            self?.showOtherProfile(handle: handle)
        }
        vc.commentsTapped = { [weak self] postID in
            self?.showComments(postID: postID)
        }
        vc.shareTapped = { [weak self] text in
            self?.presentShareSheet(text: text, from: vc)
        }

        navigationController.viewControllers = [vc]
    }

    private func presentShareSheet(text: String, from viewController: UIViewController) {
        let activityViewController = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        viewController.present(activityViewController, animated: true)
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

        navigationController.pushViewController(vc, animated: true)
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
