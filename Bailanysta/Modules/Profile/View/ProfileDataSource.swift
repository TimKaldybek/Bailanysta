//
//  ProfileDataSource.swift
//  Bailanysta
//

import UIKit

final class ProfileDataSource {

    private let diffableDataSource: UICollectionViewDiffableDataSource<ProfileSection, ProfileItem>

    init(
        collectionView: UICollectionView,
        onEditProfileTapped: @escaping () -> Void,
        onShareTapped: @escaping (String) -> Void,
        onTabSelected: @escaping (ProfileTab) -> Void,
        onAvatarTapped: @escaping (ProfilePostViewData) -> Void,
        onCommentsTapped: @escaping (UUID) -> Void,
        onComingSoonEngagementTapped: @escaping () -> Void
    ) {
        diffableDataSource = Self.makeDataSource(
            collectionView: collectionView,
            onEditProfileTapped: onEditProfileTapped,
            onShareTapped: onShareTapped,
            onTabSelected: onTabSelected,
            onAvatarTapped: onAvatarTapped,
            onCommentsTapped: onCommentsTapped,
            onComingSoonEngagementTapped: onComingSoonEngagementTapped
        )
    }

    // MARK: - Public

    func itemIdentifier(for indexPath: IndexPath) -> ProfileItem? {
        diffableDataSource.itemIdentifier(for: indexPath)
    }

    func reload(_ viewData: ProfileViewData) {
        var snapshot = NSDiffableDataSourceSnapshot<ProfileSection, ProfileItem>()
        snapshot.appendSections(ProfileSection.allCases)
        snapshot.appendItems(
            [.header(ProfileHeaderCellViewData(header: viewData.header, selectedTab: viewData.selectedTab))],
            toSection: .header
        )
        if viewData.items.isEmpty {
            snapshot.appendItems([.empty(viewData.emptyStateMessage)], toSection: .posts)
        } else {
            snapshot.appendItems(viewData.items.map { .post($0) }, toSection: .posts)
        }
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private

private extension ProfileDataSource {
    static func makeDataSource(
        collectionView: UICollectionView,
        onEditProfileTapped: @escaping () -> Void,
        onShareTapped: @escaping (String) -> Void,
        onTabSelected: @escaping (ProfileTab) -> Void,
        onAvatarTapped: @escaping (ProfilePostViewData) -> Void,
        onCommentsTapped: @escaping (UUID) -> Void,
        onComingSoonEngagementTapped: @escaping () -> Void
    ) -> UICollectionViewDiffableDataSource<ProfileSection, ProfileItem> {
        let headerCell = UICollectionView.CellRegistration<ProfileHeaderCell, ProfileHeaderCellViewData> { cell, _, viewData in
            cell.configure(with: viewData)
            cell.onEditProfileTapped = onEditProfileTapped
            cell.onShareTapped = onShareTapped
            cell.onTabSelected = onTabSelected
        }
        let postCell = UICollectionView.CellRegistration<ProfilePostCell, ProfilePostViewData> { cell, _, viewData in
            cell.configure(with: viewData)
            cell.onAvatarTapped = { onAvatarTapped(viewData) }
            cell.onCommentsTapped = { onCommentsTapped(viewData.id) }
            cell.onComingSoonEngagementTapped = onComingSoonEngagementTapped
        }
        let emptyStateCell = UICollectionView.CellRegistration<ProfileEmptyStateCell, String> { cell, _, message in
            cell.configure(with: message)
        }

        return UICollectionViewDiffableDataSource<ProfileSection, ProfileItem>(
            collectionView: collectionView
        ) { cv, indexPath, item in
            switch item {
            case .header(let viewData):
                return cv.dequeueConfiguredReusableCell(using: headerCell, for: indexPath, item: viewData)
            case .post(let viewData):
                return cv.dequeueConfiguredReusableCell(using: postCell, for: indexPath, item: viewData)
            case .empty(let message):
                return cv.dequeueConfiguredReusableCell(using: emptyStateCell, for: indexPath, item: message)
            }
        }
    }
}
