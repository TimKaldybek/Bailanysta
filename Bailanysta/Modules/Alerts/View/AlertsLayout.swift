//
//  AlertsLayout.swift
//  Bailanysta
//

import UIKit

enum AlertsLayout {
    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = AlertsSection(rawValue: sectionIndex) else { return nil }
            return notificationsSection(hasHeader: section.headerTitle != nil)
        }
    }
}

// MARK: - Sections

private extension AlertsLayout {
    /// Секция уведомлений: вертикальный список карточек, высота под контент (self-sizing)
    static func notificationsSection(hasHeader: Bool) -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(140))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(140)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 20, bottom: 20, trailing: 20)
        if hasHeader {
            section.boundarySupplementaryItems = [header()]
        }
        return section
    }

    static func header() -> NSCollectionLayoutBoundarySupplementaryItem {
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(20)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        header.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: nil, top: nil, trailing: nil, bottom: .fixed(12))
        return header
    }
}
