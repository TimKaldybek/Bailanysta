//
//  CommentsCoordinator.swift
//  Bailanysta
//

import UIKit

final class CommentsCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?
    let navigationController: UINavigationController
    private let postID: UUID

    init(navigationController: UINavigationController, postID: UUID) {
        self.navigationController = navigationController
        self.postID = postID
    }

    func start() {
        let vc = ModuleFactory.createCommentsModule(postID: postID)
        navigationController.pushViewController(vc, animated: true)
    }
}
