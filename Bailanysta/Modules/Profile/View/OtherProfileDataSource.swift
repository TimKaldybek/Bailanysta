//
//  OtherProfileDataSource.swift
//  Bailanysta
//

import UIKit

final class OtherProfileDataSource {

    private let diffableDataSource: UICollectionViewDiffableDataSource<OtherProfileSection, OtherProfileItem>

    init(collectionView: UICollectionView, onAvatarTapped: @escaping (ProfilePostViewData) -> Void) {
        diffableDataSource = Self.makeDataSource(collectionView: collectionView, onAvatarTapped: onAvatarTapped)
    }

    // MARK: - Public

    func reload(items: [OtherProfileItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<OtherProfileSection, OtherProfileItem>()
        snapshot.appendSections(OtherProfileSection.allCases)
        snapshot.appendItems(items, toSection: .posts)
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private

private extension OtherProfileDataSource {
    static func makeDataSource(
        collectionView: UICollectionView,
        onAvatarTapped: @escaping (ProfilePostViewData) -> Void
    ) -> UICollectionViewDiffableDataSource<OtherProfileSection, OtherProfileItem> {
        let postCell = UICollectionView.CellRegistration<ProfilePostCell, ProfilePostViewData> { cell, _, viewData in
            cell.configure(with: viewData)
            cell.onAvatarTapped = { onAvatarTapped(viewData) }
        }
        let skeletonCell = UICollectionView.CellRegistration<ProfilePostSkeletonCell, Int> { _, _, _ in }

        return UICollectionViewDiffableDataSource<OtherProfileSection, OtherProfileItem>(
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
