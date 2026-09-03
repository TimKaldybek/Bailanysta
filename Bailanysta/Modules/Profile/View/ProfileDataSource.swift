//
//  ProfileDataSource.swift
//  Bailanysta
//

import UIKit

final class ProfileDataSource {

    private let diffableDataSource: UICollectionViewDiffableDataSource<ProfileSection, ProfileItem>

    init(collectionView: UICollectionView) {
        diffableDataSource = Self.makeDataSource(collectionView: collectionView)
    }

    // MARK: - Public

    func itemIdentifier(for indexPath: IndexPath) -> ProfileItem? {
        diffableDataSource.itemIdentifier(for: indexPath)
    }

    func reload(items: [ProfilePostViewData]) {
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSection, ProfileItem>()
        snapshot.appendSections(ProfileSection.allCases)
        snapshot.appendItems(items.map { .post($0) }, toSection: .posts)
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private

private extension ProfileDataSource {
    static func makeDataSource(collectionView: UICollectionView) -> UICollectionViewDiffableDataSource<ProfileSection, ProfileItem> {
        let postCell = UICollectionView.CellRegistration<ProfilePostCell, ProfilePostViewData> { cell, _, viewData in
            cell.configure(with: viewData)
        }

        return UICollectionViewDiffableDataSource<ProfileSection, ProfileItem>(
            collectionView: collectionView
        ) { cv, indexPath, item in
            switch item {
            case .post(let viewData):
                return cv.dequeueConfiguredReusableCell(using: postCell, for: indexPath, item: viewData)
            }
        }
    }
}
