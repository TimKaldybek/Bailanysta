//
//  MainFlowCoordinator.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

import UIKit

final class MainFlowCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?
    let navigationController: UINavigationController
    private var childCoordinator: SettingsCoordinator?
    private var tabBarCoordinator: TabBarCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showTabBarFlow()
    }

    private func showTabBarFlow() {
        let coordinator = CoordinatorFactory.tabBarCoordinator(navigationController: navigationController)

        tabBarCoordinator = coordinator

        coordinator.onComposeTapped = { [weak self] in
            self?.showMainFlow()
        }

        coordinator.start()
    }

    private func showMainFlow() {
        navigationController.setNavigationBarHidden(false, animated: false)

        let gameVC = ModuleFactory.createMainModule()
        
        gameVC.flowSelected = { [weak self] selectedFlow in
            switch selectedFlow {
            case .subscription:
                self?.showSubscriptionFlow()
            case .playGame(let selectedThemes):
                self?.handlePlayGameFlow(selectedThemes: selectedThemes)
            case .playFunGame(let selectedThemes):
                self?.handleFunGameFlow(selectedThemes: selectedThemes)
            case .settings:
                self?.showSettingsFlow()
            case .webArticle(let url):
                self?.openArticle(url: url)
            }
        }
        
        navigationController.pushViewController(gameVC, animated: true)
    }
    
    private func handlePlayGameFlow(selectedThemes: [ThemeType]) {
        guard !selectedThemes.isEmpty else {
            completionHandler?()
            
            return
        }
        
        showQuestionFlow(selectedThemes: selectedThemes)
    }
    
    private func handleFunGameFlow(selectedThemes: [ThemeType]) {
        guard !selectedThemes.isEmpty else {
            completionHandler?()
            return
        }
        let funGameVC = ModuleFactory.createFunGameModule(selectedThemes: selectedThemes)
        funGameVC.completionHandler = { [weak self] in
            self?.navigationController.popViewController(animated: true)
            guard !SubscriptionManager.shared.isPremium() else { return }
            self?.showSubscriptionFlow()
        }
        navigationController.pushViewController(funGameVC, animated: true)
    }

    private func showQuestionFlow(selectedThemes: [ThemeType]) {
        let diceAnimationVC = ModuleFactory.createDiceAnimationFlow(selectedThemes: selectedThemes)
        
        diceAnimationVC.completionHandler = { [weak self] in
            self?.navigationController.popViewController(animated: true)
            
            guard !SubscriptionManager.shared.isPremium() else { return }
            
            self?.showSubscriptionFlow()
        }
        
        navigationController.pushViewController(diceAnimationVC, animated: true)
    }
    
    private func showSubscriptionFlow() {
        let subscriptionVC = ModuleFactory.createSubscriptionModule()
        
        subscriptionVC.completionHandler = { [weak self] output in
            guard let self else { return }
                        
            switch output {
            case .openTermAndCondition(let url):
                openTermAndCondition(with: url)
            case .openSubscriptionDetails:
                openSubscriptionDetailsViewController()
            case .close:
                navigationController.popViewController(animated: true)
                completionHandler?()
            }
        }
        
        navigationController.pushViewController(subscriptionVC, animated: true)
    }
    
    private func showSettingsFlow() {
        let settingsFlowCoordinator = CoordinatorFactory.settingsCoordinator(navigationController: navigationController)
        
        childCoordinator = settingsFlowCoordinator
        
        settingsFlowCoordinator.completionHandler = { [weak self] in
            self?.completionHandler?()
        }
        
        settingsFlowCoordinator.start()
    }
    
    private func openSubscriptionDetailsViewController() {
        let vc = ModuleFactory.createSubscriptionDetailsModule()

        if let sheet = vc.sheetPresentationController {
            sheet.detents = [.custom { _ in 700 }]
            sheet.prefersGrabberVisible = true
            sheet.preferredCornerRadius = 16
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
        }

        navigationController.present(vc, animated: true)
    }
    
    private func openTermAndCondition(with url: URL) {
        let wv = WebViewController(url: url)
        navigationController.present(wv, animated: true)
    }

    private func openArticle(url: URL) {
        let wv = WebViewController(url: url)
        navigationController.present(wv, animated: true)
    }
}
