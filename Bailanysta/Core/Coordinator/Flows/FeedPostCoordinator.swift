//
//  FeedPostCoordinator.swift
//  Bailanysta
//

import UIKit

final class FeedPostCoordinator: NSObject, Coordinator {
    var completionHandler: CoordinatorHandler?

    let navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = ModuleFactory.createFeedPostModule()

        vc.didFinish = { [weak self] in
            self?.dismiss()
        }

        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.large()]
            sheet.prefersGrabberVisible = true
        }
        vc.presentationController?.delegate = self

        navigationController.present(vc, animated: true)
    }

    private func dismiss() {
        navigationController.dismiss(animated: true)
        completionHandler?()
    }
}

// MARK: - UIAdaptivePresentationControllerDelegate

extension FeedPostCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        completionHandler?()
    }
}
