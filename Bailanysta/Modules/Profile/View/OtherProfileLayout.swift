//
//  OtherProfileLayout.swift
//  Bailanysta
//

import UIKit

enum OtherProfileLayout {
    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard OtherProfileSection(rawValue: sectionIndex) != nil else { return nil }
            return postsSection()
        }
    }
}

// MARK: - Sections

private extension OtherProfileLayout {
    /// Секция постов чужого профиля: вертикальный список, полная ширина, высота под контент (self-sizing)
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
