//
//  AppTheme.swift
//  Bailanysta
//

import UIKit

/// The set of appearances the app can be switched to. `.system` follows the device's setting;
/// `.light`/`.dark` pin the app to that appearance regardless of the device setting.
enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    var userInterfaceStyle: UIUserInterfaceStyle {
        switch self {
        case .system: .unspecified
        case .light: .light
        case .dark: .dark
        }
    }

    var displayName: String {
        switch self {
        case .system: "SettingsVC.Appearance.System".localized
        case .light: "SettingsVC.Appearance.Light".localized
        case .dark: "SettingsVC.Appearance.Dark".localized
        }
    }
}
