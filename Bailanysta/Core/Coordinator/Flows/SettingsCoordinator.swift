//
//  SettingsCoordinator.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 09.12.2024.
//

import UIKit
import UserNotifications

final class SettingsCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?
    
    let navigationController: UINavigationController
    private let activityViewController: UIActivityViewController
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        self.activityViewController = UIActivityViewController(
            activityItems: [GlobalConstants.appStoreURL],
            applicationActivities: nil
        )
    }
    
    func start() {
        let vc = ModuleFactory.createSettingsModule()
    
        vc.completionHandler = { [weak self] settingType in
            self?.handleSelected(settingType)
        }
        
        navigationController.pushViewController(vc, animated: true)
    }
    
    private func handleSelected(_ settingType: SettingType) {
        switch settingType {
        case .language:
            showSettingsFlow()
        case .feedback:
            showFeedbackVC()
        case .share:
            navigationController.present(activityViewController, animated: true)
        case .notifications:
            handleNotificationsTap()
        }
    }
    
    private func handleNotificationsTap() {
        NotificationManager.shared.checkAuthorizationStatus { [weak self] status in
            switch status {
            case .notDetermined:
                NotificationManager.shared.requestPermissionAndSchedule()
            case .denied:
                self?.showSettingsFlow()
            case .authorized, .provisional, .ephemeral:
                self?.showSettingsFlow()
            @unknown default:
                self?.showSettingsFlow()
            }
        }
    }

    private func showSettingsFlow() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            showAlert(title: "Error".localized, message: "Error.load.settings".localized)
            
            return
        }
        
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        UIApplication.shared.open(url)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK".localized, style: .default))
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        navigationController.present(alert, animated: true)
    }
    
    private func showFeedbackVC() {
        let feedbackVC = ModuleFactory.createFeedbackModule { [weak self] status in
            guard let self else {
                self?.completionHandler?()
                return
            }
            
            navigationController.dismiss(animated: false)
            
            switch status {
            case let .success(title, subtitle):
                showAlert(title: title, message: subtitle)
            case let .failure(title, subtitle):
                showAlert(title: title, message: subtitle)
            }
        }
        
        feedbackVC.modalPresentationStyle = .overFullScreen
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
    
        navigationController.present(feedbackVC, animated: true)
    }
}
