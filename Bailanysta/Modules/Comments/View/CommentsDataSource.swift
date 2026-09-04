//
//  CommentsDataSource.swift
//  Bailanysta
//

import UIKit

final class CommentsDataSource {

    private let diffableDataSource: UICollectionViewDiffableDataSource<CommentsSection, CommentsItem>

    init(collectionView: UICollectionView) {
        diffableDataSource = Self.makeDataSource(collectionView: collectionView)
    }

    // MARK: - Public

    func reload(comments: [CommentViewData]) {
        var snapshot = NSDiffableDataSourceSnapshot<CommentsSection, CommentsItem>()
        snapshot.appendSections(CommentsSection.allCases)
        snapshot.appendItems(comments.map { .comment($0) }, toSection: .comments)
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private

private extension CommentsDataSource {
    static func makeDataSource(
        collectionView: UICollectionView
    ) -> UICollectionViewDiffableDataSource<CommentsSection, CommentsItem> {
        let commentCell = UICollectionView.CellRegistration<CommentCell, CommentViewData> { cell, _, viewData in
            cell.configure(with: viewData)
        }

        return UICollectionViewDiffableDataSource<CommentsSection, CommentsItem>(
            collectionView: collectionView
        ) { cv, indexPath, item in
            switch item {
            case .comment(let viewData):
                return cv.dequeueConfiguredReusableCell(using: commentCell, for: indexPath, item: viewData)
            }
        }
    }
}
