//
//  SearchLayout.swift
//  Bailanysta
//

import UIKit

enum SearchLayout {
    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = SearchSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .trending: return trendingSection()
            case .suggested: return suggestedSection()
            }
        }
    }
}

// MARK: - Sections

private extension SearchLayout {
    /// Секция трендов: вертикальный список карточек фиксированной высоты, полная ширина
    static func trendingSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 24, trailing: 20)
        section.boundarySupplementaryItems = [header()]
        return section
    }

    /// Секция рекомендованных пользователей: вертикальный список строк фиксированной высоты, полная ширина
    static func suggestedSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(64))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(64)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 20, bottom: 24, trailing: 20)
        section.boundarySupplementaryItems = [header()]
        return section
    }

    static func header() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(28)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
