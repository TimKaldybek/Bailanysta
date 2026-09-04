//
//  CommentsLayout.swift
//  Bailanysta
//

import UIKit

enum CommentsLayout {
    static func make() -> UICollectionViewCompositionalLayout {
        UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = CommentsSection(rawValue: sectionIndex) else { return nil }
            switch section {
            case .comments: return commentsSection()
            }
        }
    }
}

// MARK: - Sections

private extension CommentsLayout {
    /// Секция комментариев: вертикальный список, полная ширина, высота под контент (self-sizing)
    static func commentsSection() -> NSCollectionLayoutSection {
        let item = NSCollectionLayoutItem(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(90))
        )
        let group = NSCollectionLayoutGroup.vertical(
            layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(90)),
            subitems: [item]
        )
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        return section
    }
}
