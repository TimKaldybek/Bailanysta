//
//  FeedLayout.swift
//  Bailanysta
//

import UIKit

enum FeedLayout {
    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = FeedSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .posts: return postsSection()
            }
        }
    }
}

// MARK: - Sections

private extension FeedLayout {
    /// Секция постов: вертикальный список, полная ширина, высота под контент (self-sizing)
    static func postsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(320))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(320)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }
}
