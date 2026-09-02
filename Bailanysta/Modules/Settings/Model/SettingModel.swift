//
//  SettingModel.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 09.12.2024.
//

import UIKit

struct SettingModel {
    let type: SettingType
    let title: String
    let selectedLanguage: String?
    let iconType: SettingIconType
    let sfSymbolName: String
    let accentColor: UIColor

    init(
        type: SettingType,
        title: String,
        selectedLanguage: String? = nil,
        iconType: SettingIconType,
        sfSymbolName: String,
        accentColor: UIColor
    ) {
        self.type = type
        self.title = title
        self.selectedLanguage = selectedLanguage
        self.iconType = iconType
        self.sfSymbolName = sfSymbolName
        self.accentColor = accentColor
    }
}
