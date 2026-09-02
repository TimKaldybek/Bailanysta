//
//  ThemeSection.swift
//  Bailanysta
//

enum ThemeSection: Int, CaseIterable, Hashable {
    case deep
    case quickGame
    case fun
    case tip
    case articles

    var header: String {
        switch self {
        case .quickGame: return ""
        case .deep:      return "Section.Deep.Header".localized
        case .fun:       return "Section.Fun.Header".localized
        case .tip:       return "Section.Tip.Header".localized
        case .articles:  return "Section.Articles.Header".localized
        }
    }

}
