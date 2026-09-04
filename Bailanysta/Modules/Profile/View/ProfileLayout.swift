//
//  ProfileLayout.swift
//  Bailanysta
//

import UIKit

enum ProfileLayout {
    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = ProfileSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .header: return headerSection()
            case .posts: return postsSection()
            }
        }
    }
}

// MARK: - Sections

private extension ProfileLayout {
    /// Секция карточки профиля: один самосайзящийся элемент на всю ширину, скроллится вместе с лентой
    static func headerSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(360))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(360)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 16, bottom: 12, trailing: 16)
        return section
    }

    /// Секция постов профиля: вертикальный список, полная ширина, высота под контент (self-sizing)
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
