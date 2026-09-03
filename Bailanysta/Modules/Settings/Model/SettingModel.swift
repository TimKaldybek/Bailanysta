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
    let trailingText: String?
    let iconType: SettingIconType
    let sfSymbolName: String
    let accentColor: UIColor

    init(
        type: SettingType,
        title: String,
        trailingText: String? = nil,
        iconType: SettingIconType,
        sfSymbolName: String,
        accentColor: UIColor
    ) {
        self.type = type
        self.title = title
        self.trailingText = trailingText
        self.iconType = iconType
        self.sfSymbolName = sfSymbolName
        self.accentColor = accentColor
    }
}
