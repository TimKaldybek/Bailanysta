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
        onCommentsTapped: @escaping (UUID) -> Void,
        onShareTapped: @escaping (FeedPostViewData) -> Void,
        onCardTapped: @escaping (UUID) -> Void
    ) {
        diffableDataSource = Self.makeDataSource(
            collectionView: collectionView,
            onAvatarTapped: onAvatarTapped,
            onLikeTapped: onLikeTapped,
            onCommentsTapped: onCommentsTapped,
            onShareTapped: onShareTapped,
            onCardTapped: onCardTapped
        )
    }

    // MARK: - Public

    func itemIdentifier(for indexPath: IndexPath) -> FeedItem? {
        diffableDataSource.itemIdentifier(for: indexPath)
    }

    func reload(items: [FeedItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<FeedSection, FeedItem>()
        snapshot.appendSections(FeedSection.allCases)
        snapshot.appendItems(items, toSection: .posts)
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private

private extension FeedDataSource {
    static func makeDataSource(
        collectionView: UICollectionView,
        onAvatarTapped: @escaping (FeedPostViewData) -> Void,
        onLikeTapped: @escaping (UUID) -> Void,
        onCommentsTapped: @escaping (UUID) -> Void,
        onShareTapped: @escaping (FeedPostViewData) -> Void,
        onCardTapped: @escaping (UUID) -> Void
    ) -> UICollectionViewDiffableDataSource<FeedSection, FeedItem> {
        let postCell = UICollectionView.CellRegistration<FeedPostCell, FeedPostViewData> { cell, _, viewData in
            cell.configure(with: viewData)
            cell.onAvatarTapped = { onAvatarTapped(viewData) }
            cell.onLikeTapped = { onLikeTapped(viewData.id) }
            cell.onCommentsTapped = { onCommentsTapped(viewData.id) }
            cell.onShareTapped = { onShareTapped(viewData) }
            cell.onCardTapped = { onCardTapped(viewData.id) }
        }
        let skeletonCell = UICollectionView.CellRegistration<FeedSkeletonCell, Int> { _, _, _ in }

        return UICollectionViewDiffableDataSource<FeedSection, FeedItem>(
            collectionView: collectionView
        ) { cv, indexPath, item in
            switch item {
            case .post(let viewData):
                return cv.dequeueConfiguredReusableCell(using: postCell, for: indexPath, item: viewData)
            case .skeleton(let index):
                return cv.dequeueConfiguredReusableCell(using: skeletonCell, for: indexPath, item: index)
            }
        }
    }
}
