//
//  SearchDataSource.swift
//  Bailanysta
//

import UIKit

final class SearchDataSource {

    private var diffableDataSource: UICollectionViewDiffableDataSource<SearchSection, SearchItem>!

    init(
        collectionView: UICollectionView,
        onSuggestedUserProfileTapped: @escaping (SuggestedUserViewData) -> Void,
        onSuggestedUserFollowTapped: @escaping (SuggestedUserViewData) -> Void
    ) {
        configure(
            collectionView: collectionView,
            onSuggestedUserProfileTapped: onSuggestedUserProfileTapped,
            onSuggestedUserFollowTapped: onSuggestedUserFollowTapped
        )
    }

    // MARK: - Public

    func itemIdentifier(for indexPath: IndexPath) -> SearchItem? {
        diffableDataSource.itemIdentifier(for: indexPath)
    }

    func reload(trendingTopics: [TrendingTopicViewData], suggestedUsers: [SuggestedUserViewData]) {
        var snapshot = NSDiffableDataSourceSnapshot<SearchSection, SearchItem>()
        snapshot.appendSections(SearchSection.allCases)
        snapshot.appendItems(trendingTopics.map { .trending($0) }, toSection: .trending)
        snapshot.appendItems(suggestedUsers.map { .suggestedUser($0) }, toSection: .suggested)
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private

private extension SearchDataSource {
    func configure(
        collectionView: UICollectionView,
        onSuggestedUserProfileTapped: @escaping (SuggestedUserViewData) -> Void,
        onSuggestedUserFollowTapped: @escaping (SuggestedUserViewData) -> Void
    ) {
        let trendingCell = UICollectionView.CellRegistration<TrendingTopicCell, TrendingTopicViewData> { cell, _, viewData in
            cell.configure(with: viewData)
        }
        let suggestedCell = UICollectionView.CellRegistration<SuggestedUserCell, SuggestedUserViewData> { cell, _, viewData in
            cell.configure(with: viewData)
            cell.onProfileTapped = { onSuggestedUserProfileTapped(viewData) }
            cell.onFollowTapped = { onSuggestedUserFollowTapped(viewData) }
        }
        let sectionHeader = UICollectionView.SupplementaryRegistration<SearchSectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { view, _, indexPath in
            guard let section = SearchSection(rawValue: indexPath.section) else { return }
            view.configure(title: section.header.title, systemIcon: section.header.systemIcon)
        }

        diffableDataSource = UICollectionViewDiffableDataSource<SearchSection, SearchItem>(
            collectionView: collectionView
        ) { cv, indexPath, item in
            switch item {
            case .trending(let viewData):
                return cv.dequeueConfiguredReusableCell(using: trendingCell, for: indexPath, item: viewData)
            case .suggestedUser(let viewData):
                return cv.dequeueConfiguredReusableCell(using: suggestedCell, for: indexPath, item: viewData)
            }
        }

        diffableDataSource.supplementaryViewProvider = { cv, _, indexPath in
            cv.dequeueConfiguredReusableSupplementary(using: sectionHeader, for: indexPath)
        }
    }
}
