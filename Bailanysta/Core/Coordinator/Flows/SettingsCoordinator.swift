//
//  SettingsCoordinator.swift
//  Bailanysta
//
//

import UIKit
import UserNotifications

final class SettingsCoordinator: Coordinator {
    var completionHandler: CoordinatorHandler?
    
    let navigationController: UINavigationController
    private let activityViewController: UIActivityViewController
    private weak var settingsViewController: SettingsViewController?

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
        settingsViewController = vc

        navigationController.pushViewController(vc, animated: true)
    }

    private func handleSelected(_ settingType: SettingType) {
        switch settingType {
        case .appearance:
            showAppearancePicker()
        case .language:
            showSettingsFlow()
        case .share:
            navigationController.present(activityViewController, animated: true)
        case .notifications:
            handleNotificationsTap()
        case .logout:
            showLogoutConfirmation()
        }
    }

    private func showLogoutConfirmation() {
        let alert = UIAlertController(
            title: "SettingsVC.LogoutConfirmation.Title".localized,
            message: "SettingsVC.LogoutConfirmation.Message".localized,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: "SettingsVC.Logout".localized, style: .destructive) { [weak self] _ in
            do {
                try SessionManager.shared.signOut()
            } catch {
                self?.showAlert(title: "Error".localized, message: "Auth.Error.Generic".localized)
            }
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))

        navigationController.present(alert, animated: true)
    }

    private func showAppearancePicker() {
        let picker = UIAlertController(title: "SettingsVC.Appearance".localized, message: nil, preferredStyle: .alert)

        AppTheme.allCases.forEach { theme in
            picker.addAction(UIAlertAction(title: theme.displayName, style: .default) { [weak self] _ in
                ThemeManager.shared.apply(theme)
                self?.settingsViewController?.reloadSettings()
            })
        }
        picker.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))

        navigationController.present(picker, animated: true)
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
}
