//
//  MainLayout.swift
//  Bailanysta
//

import UIKit

enum MainLayout {

    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = ThemeSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .deep:      return deepSection()
            case .quickGame: return quickGameSection()
            case .fun:       return funSection()
            case .tip:       return tipSection()
            case .articles:  return articlesSection()
            }
        }
    }
}

// MARK: - Sections

private extension MainLayout {

    /// Секция 0: баннер быстрой игры — полная ширина, высота 88pt, без заголовка
    static func quickGameSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(88))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(88)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16)
        return section
    }

    /// Секция 1: квадратные карточки 160×190, непрерывный горизонтальный скролл
    static func deepSection() -> NSCollectionLayoutSection {
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .absolute(160), heightDimension: .absolute(190)),
            subitems: [fullItem()]
        )
        return makeSection(group: group, scrollBehavior: .continuous)
    }

    /// Секция 2: карточки на пол-экрана (2 видны одновременно), высота 154pt, скролл постранично
    static func funSection() -> NSCollectionLayoutSection {
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: .init(widthDimension: .fractionalWidth(0.46), heightDimension: .absolute(154)),
            subitems: [fullItem()]
        )
        return makeSection(group: group, scrollBehavior: .groupPaging)
    }

    /// Секция 3: вертикальный список советов для пары, полная ширина, высота self-sizing
    static func tipSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(100)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
        section.boundarySupplementaryItems = [header()]
        return section
    }

    /// Секция 4: вертикальный список статей, полная ширина, высота 72pt
    static func articlesSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(72))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(72)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 8
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 32, trailing: 16)
        section.boundarySupplementaryItems = [header()]
        return section
    }

    // MARK: - Helpers

    static func fullItem() -> NSCollectionLayoutItem {
        NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        )
    }

    static func makeSection(
        group: NSCollectionLayoutGroup,
        scrollBehavior: UICollectionLayoutSectionOrthogonalScrollingBehavior
    ) -> NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = scrollBehavior
        section.interGroupSpacing = 12
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16)
        section.boundarySupplementaryItems = [header()]
        return section
    }

    static func header() -> NSCollectionLayoutBoundarySupplementaryItem {
        NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(50)),
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
    }
}
