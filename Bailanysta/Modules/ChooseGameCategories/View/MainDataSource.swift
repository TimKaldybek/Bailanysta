//
//  MainDataSource.swift
//  Bailanysta
//

import UIKit

final class MainDataSource {

    private var diffableDataSource: UICollectionViewDiffableDataSource<ThemeSection, SectionItem>!

    init(
        collectionView: UICollectionView,
        items: (ThemeSection) -> [SectionItem],
        modelProvider: @escaping (ThemeType) -> ThemeModel?
    ) {
        configure(collectionView: collectionView, modelProvider: modelProvider)
        applySnapshot(items: items)
    }

    // MARK: - Public

    func itemIdentifier(for indexPath: IndexPath) -> SectionItem? {
        diffableDataSource.itemIdentifier(for: indexPath)
    }

    func reload(items: (ThemeSection) -> [SectionItem]) {
        applySnapshot(items: items)
    }

    func reconfigure(types: [ThemeType]) {
        var snapshot = diffableDataSource.snapshot()
        snapshot.reconfigureItems(types.map { .theme($0) })
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}

// MARK: - Private

private extension MainDataSource {

    func configure(collectionView: UICollectionView, modelProvider: @escaping (ThemeType) -> ThemeModel?) {
        let quickGameCell = UICollectionView.CellRegistration<QuickGameCollectionViewCell, Void> { _, _, _ in }
        let tipCell = UICollectionView.CellRegistration<RelationshipTipCollectionViewCell, RelationshipTip> { cell, _, tip in
            cell.configure(with: tip)
        }
        let articleCell   = UICollectionView.CellRegistration<ArticleCollectionViewCell, ArticleItem> { cell, _, item in
            cell.configure(with: item)
        }
        let funCell = UICollectionView.CellRegistration<FunThemeCollectionViewCell, ThemeModel> { cell, _, model in
            cell.configure(with: model)
        }
        let deepCell = UICollectionView.CellRegistration<GameThemeCollectionViewCell, ThemeModel> { cell, _, model in
            cell.configure(with: model)
        }
        let sectionHeader = UICollectionView.SupplementaryRegistration<SectionHeaderView>(
            elementKind: UICollectionView.elementKindSectionHeader
        ) { view, _, indexPath in
            guard let section = ThemeSection(rawValue: indexPath.section) else { return }
            view.configure(title: section.header)
        }

        diffableDataSource = UICollectionViewDiffableDataSource<ThemeSection, SectionItem>(
            collectionView: collectionView
        ) { cv, indexPath, item in
            switch item {
            case .quickGame:
                return cv.dequeueConfiguredReusableCell(using: quickGameCell, for: indexPath, item: ())

            case .tip(let tip):
                return cv.dequeueConfiguredReusableCell(using: tipCell, for: indexPath, item: tip)

            case .article(let article):
                return cv.dequeueConfiguredReusableCell(using: articleCell, for: indexPath, item: article)

            case .theme(let type):
                guard let model = modelProvider(type) else { return UICollectionViewCell() }
                if ThemeSection(rawValue: indexPath.section) == .fun {
                    return cv.dequeueConfiguredReusableCell(using: funCell, for: indexPath, item: model)
                } else {
                    return cv.dequeueConfiguredReusableCell(using: deepCell, for: indexPath, item: model)
                }
            }
        }

        diffableDataSource.supplementaryViewProvider = { cv, _, indexPath in
            cv.dequeueConfiguredReusableSupplementary(using: sectionHeader, for: indexPath)
        }
    }

    func applySnapshot(items: (ThemeSection) -> [SectionItem]) {
        var snapshot = NSDiffableDataSourceSnapshot<ThemeSection, SectionItem>()
        snapshot.appendSections(ThemeSection.allCases)
        ThemeSection.allCases.forEach { snapshot.appendItems(items($0), toSection: $0) }
        diffableDataSource.apply(snapshot, animatingDifferences: false)
    }
}
