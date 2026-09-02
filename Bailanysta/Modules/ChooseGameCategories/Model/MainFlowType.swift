//
//  MainFlowType.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 07.12.2024.
//

import Foundation

enum MainFlowType {
    case subscription
    case playGame([ThemeType])
    case playFunGame([ThemeType])
    case settings
    case webArticle(URL)
}
