//
//  SettingsPresenter.swift
//  Bailanysta
//

import UIKit

final class SettingsPresenter {
    var model: [SettingModel] {
        [
            SettingModel(
                type: .appearance,
                title: "SettingsVC.Appearance".localized,
                trailingText: ThemeManager.shared.currentTheme.displayName,
                iconType: .arrow,
                sfSymbolName: "circle.lefthalf.filled",
                accentColor: Color.accentIndigo
            ),
            SettingModel(
                type: .language,
                title: "SettingsVC.InterfaceLanguage".localized,
                trailingText: Locale.current.languageCode ?? "undefined",
                iconType: .arrow,
                sfSymbolName: "globe",
                accentColor: Color.accentBlue
            ),
            SettingModel(
                type: .share,
                title: "SettingsVC.ShareApp".localized,
                iconType: .arrow,
                sfSymbolName: "square.and.arrow.up",
                accentColor: Color.accentGreen
            ),
            SettingModel(
                type: .notifications,
                title: "SettingsVC.Notifications".localized,
                iconType: .arrow,
                sfSymbolName: "bell.fill",
                accentColor: Color.accentRed
            ),
            SettingModel(
                type: .logout,
                title: "SettingsVC.Logout".localized,
                iconType: .arrow,
                sfSymbolName: "rectangle.portrait.and.arrow.right",
                accentColor: Color.accentRed
            )
        ]
    }
}
