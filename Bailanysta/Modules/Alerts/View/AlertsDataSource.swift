//
//  AlertsDataSource.swift
//  Bailanysta
//

import UIKit

final class AlertsDataSource {

    private let diffableDataSource: UICollectionViewDiffableDataSource<AlertsSection, AlertsItem>

    init(collectionView: UICollectionView, onAction: @escaping (UUID, AlertNotificationCell.ActionKind) -> Void) {
        diffableDataSource = Self.makeDataSource(collectionView: collectionView, onAction: onAction)
    }

    // MARK: - Public

    func reload(recent: [AlertNotificationViewData], earlier: [AlertNotificationViewData]) {
        var snapshot = NSDiffableDataSourceSnapshot<AlertsSection, AlertsItem>()
        snapshot.appendSections(AlertsSection.allCases)
        snapshot.appendItems(recent.map { .notification($0) }, toSection: .recent)
        snapshot.appendItems(earlier.map { .notification($0) }, toSection: .earlier)
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private

private extension AlertsDataSource {
    static func makeDataSource(
        collectionView: UICollectionView,
        onAction: @escaping (UUID, AlertNotificationCell.ActionKind) -> Void
    ) -> UICollectionViewDiffableDataSource<AlertsSection, AlertsItem> {
        let notificationCell = UICollectionView.CellRegistration<AlertNotificationCell, AlertNotificationViewData> { cell, _, viewData in
            cell.configure(with: viewData)
            cell.onActionTapped = { kind in
                onAction(viewData.id, kind)
            }
        }
        let sectionHeader = UICollectionView.SupplementaryRegistration<AlertsSectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { view, _, indexPath in
            guard let title = AlertsSection(rawValue: indexPath.section)?.headerTitle else { return }
            view.configure(title: title)
        }

        let dataSource = UICollectionViewDiffableDataSource<AlertsSection, AlertsItem>(
            collectionView: collectionView
        ) { cv, indexPath, item in
            switch item {
            case .notification(let viewData):
                return cv.dequeueConfiguredReusableCell(using: notificationCell, for: indexPath, item: viewData)
            }
        }

        dataSource.supplementaryViewProvider = { cv, _, indexPath in
            cv.dequeueConfiguredReusableSupplementary(using: sectionHeader, for: indexPath)
        }

        return dataSource
    }
}
