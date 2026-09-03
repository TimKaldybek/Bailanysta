//
//  AlertsSection.swift
//  Bailanysta
//

enum AlertsSection: Int, CaseIterable, Hashable {
    case recent
    case earlier

    var headerTitle: String? {
        switch self {
        case .recent: return nil
        case .earlier: return "Alerts.EarlierThisWeek".localized.uppercased()
        }
    }
}
