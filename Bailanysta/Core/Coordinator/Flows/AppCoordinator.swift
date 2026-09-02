//
//  MainCoordinator.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

import Foundation
import UIKit

final class AppCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?
    let navigationController: UINavigationController
    
    private var coordinators = [Coordinator]()
        
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showMainFlow()
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
