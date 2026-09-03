//
//  Coordinatorfactory.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

import UIKit

final class CoordinatorFactory {
    static func appCoordinator(navigationController: UINavigationController) -> AppCoordinator {
        AppCoordinator(navigationController: navigationController)
    }

    static func mainCoordinator(navigationController: UINavigationController) -> MainFlowCoordinator {
        MainFlowCoordinator(navigationController: navigationController)
    }
    
    static func settingsCoordinator(navigationController: UINavigationController) -> SettingsCoordinator {
        SettingsCoordinator(navigationController: navigationController)
    }

    static func tabBarCoordinator(navigationController: UINavigationController) -> TabBarCoordinator {
        TabBarCoordinator(navigationController: navigationController)
    }

    static func feedTabCoordinator(navigationController: UINavigationController) -> FeedTabCoordinator {
        FeedTabCoordinator(navigationController: navigationController)
    }

    static func searchTabCoordinator(navigationController: UINavigationController) -> SearchTabCoordinator {
        SearchTabCoordinator(navigationController: navigationController)
    }

    static func alertsTabCoordinator(navigationController: UINavigationController) -> AlertsTabCoordinator {
        AlertsTabCoordinator(navigationController: navigationController)
    }

    static func profileTabCoordinator(navigationController: UINavigationController) -> ProfileTabCoordinator {
        ProfileTabCoordinator(navigationController: navigationController)
    }

    static func feedPostCoordinator(navigationController: UINavigationController) -> FeedPostCoordinator {
        FeedPostCoordinator(navigationController: navigationController)
    }
}
