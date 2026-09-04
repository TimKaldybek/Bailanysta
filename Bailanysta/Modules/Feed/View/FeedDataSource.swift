//
//  FeedDataSource.swift
//  Bailanysta
//

import UIKit

final class FeedDataSource {

    private let diffableDataSource: UICollectionViewDiffableDataSource<FeedSection, FeedItem>

    init(
        collectionView: UICollectionView,
        onAvatarTapped: @escaping (FeedPostViewData) -> Void,
        onLikeTapped: @escaping (UUID) -> Void,
        onCommentsTapped: @escaping (UUID) -> Void
    ) {
        diffableDataSource = Self.makeDataSource(
            collectionView: collectionView,
            onAvatarTapped: onAvatarTapped,
            onLikeTapped: onLikeTapped,
            onCommentsTapped: onCommentsTapped
        )
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
    static func makeDataSource(
        collectionView: UICollectionView,
        onAvatarTapped: @escaping (FeedPostViewData) -> Void,
        onLikeTapped: @escaping (UUID) -> Void,
        onCommentsTapped: @escaping (UUID) -> Void
    ) -> UICollectionViewDiffableDataSource<FeedSection, FeedItem> {
        let postCell = UICollectionView.CellRegistration<FeedPostCell, FeedPostViewData> { cell, _, viewData in
            cell.configure(with: viewData)
            cell.onAvatarTapped = { onAvatarTapped(viewData) }
            cell.onLikeTapped = { onLikeTapped(viewData.id) }
            cell.onCommentsTapped = { onCommentsTapped(viewData.id) }
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
