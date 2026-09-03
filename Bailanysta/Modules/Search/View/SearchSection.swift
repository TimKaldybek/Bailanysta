//
//  SearchSection.swift
//  Bailanysta
//

enum SearchSection: Int, CaseIterable, Hashable {
    case trending
    case suggested

    var header: (title: String, systemIcon: String?) {
        switch self {
        case .trending: return ("Search.TrendingNow".localized, "chart.line.uptrend.xyaxis")
        case .suggested: return ("Search.SuggestedForYou".localized, nil)
        }
    }
}
