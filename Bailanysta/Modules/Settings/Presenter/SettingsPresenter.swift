//
//  SettingsPresenter.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 09.12.2024.
//

import UIKit

final class SettingsPresenter {
    let model = [
        SettingModel(
            type: .language,
            title: "SettingsVC.InterfaceLanguage".localized,
            selectedLanguage: Locale.current.languageCode ?? "undefined",
            iconType: .arrow,
            sfSymbolName: "globe",
            accentColor: UIColor.systemBlue
        ),
        SettingModel(
            type: .feedback,
            title: "SettingsVC.GiveFeedback".localized,
            iconType: .arrow,
            sfSymbolName: "star.fill",
            accentColor: UIColor.systemOrange
        ),
        SettingModel(
            type: .share,
            title: "SettingsVC.ShareApp".localized,
            iconType: .arrow,
            sfSymbolName: "square.and.arrow.up",
            accentColor: UIColor.systemGreen
        ),
        SettingModel(
            type: .notifications,
            title: "SettingsVC.Notifications".localized,
            iconType: .arrow,
            sfSymbolName: "bell.fill",
            accentColor: UIColor.systemRed
        )
    ]
}
