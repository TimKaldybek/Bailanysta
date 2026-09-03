//
//  FeedDataSource.swift
//  Bailanysta
//

import UIKit

final class FeedDataSource {

    private let diffableDataSource: UICollectionViewDiffableDataSource<FeedSection, FeedItem>

    init(collectionView: UICollectionView) {
        diffableDataSource = Self.makeDataSource(collectionView: collectionView)
    }

    // MARK: - Public

    func itemIdentifier(for indexPath: IndexPath) -> FeedItem? {
        diffableDataSource.itemIdentifier(for: indexPath)
    }

    func reload(posts: [FeedPostViewData]) {
        var snapshot = NSDiffableDataSourceSnapshot<FeedSection, FeedItem>()
        snapshot.appendSections(FeedSection.allCases)
        snapshot.appendItems(posts.map { .post($0) }, toSection: .posts)
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private

private extension FeedDataSource {
    static func makeDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<FeedSection, FeedItem> {
        let postCell = UICollectionView.CellRegistration<FeedPostCell, FeedPostViewData> { cell, _, viewData in
            cell.configure(with: viewData)
        }

        return UICollectionViewDiffableDataSource<FeedSection, FeedItem>(
            collectionView: collectionView
        ) { cv, indexPath, item in
            switch item {
            case .post(let viewData):
                return cv.dequeueConfiguredReusableCell(using: postCell, for: indexPath, item: viewData)
            }
        }
    }
}
