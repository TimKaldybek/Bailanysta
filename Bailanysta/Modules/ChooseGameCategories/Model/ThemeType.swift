//
//  ThemeType.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

enum ThemeType: String, Codable {
    // Section: deep
    case job
    case sex
    case dreams
    case care
    case relationship
    case random
    // Section: fun
    case neverHaveI
    case whoAmong
    case confessions
    case truthOrDare

    var description: String {
        switch self {
        case .job:          return "Theme.LifeWorkMoney".localized
        case .sex:          return "Theme.Sex".localized
        case .dreams:       return "Theme.DreamsDesires".localized
        case .care:         return "Theme.Care".localized
        case .relationship: return "Theme.Relationship".localized
        case .random:       return "Theme.Random".localized
        case .neverHaveI:   return "Theme.NeverHaveI".localized
        case .whoAmong:     return "Theme.WhoAmong".localized
        case .confessions:  return "Theme.Confessions".localized
        case .truthOrDare:  return "Theme.TruthOrDare".localized
        }
    }
}
