//
//  AlertsViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class AlertsViewController: UIViewController {

    private let presenter: AlertsPresenter
    private let dataSource: AlertsDataSource
    private let collectionView: UICollectionView

    private let headerView = AlertsHeaderView()

    // MARK: - Init

    init(presenter: AlertsPresenter) {
        self.presenter = presenter

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: AlertsLayout.make())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        self.collectionView = collectionView
        self.dataSource = AlertsDataSource(collectionView: collectionView) { [weak presenter] id, kind in
            switch kind {
            case .primary:
                presenter?.reply(to: id)
            case .accept:
                presenter?.acceptInvite(id: id)
            case .decline:
                presenter?.declineInvite(id: id)
            }
        }

        super.init(nibName: nil, bundle: nil)

        collectionView.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupUI()
        setupConstraints()
        presenter.load()
        
        headerView.onMarkAllTapped = { [weak self] in
            self?.presenter.markAllAsRead()
        }
    }
}

// MARK: - AlertsViewInput

extension AlertsViewController: AlertsViewInput {
    func display(_ viewData: AlertsViewData) {
        dataSource.reload(recent: viewData.recentNotifications, earlier: viewData.earlierNotifications)
    }
}

// MARK: - UICollectionViewDelegate

extension AlertsViewController: UICollectionViewDelegate {}

// MARK: - Private

private extension AlertsViewController {
    func setupUI() {
        view.backgroundColor = Color.background
        [headerView, collectionView].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(20)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        collectionView.contentInset.bottom = Constants.tabBarHeight
    }

    enum Constants {
        /// Высота реального таб-бара (`TabBarView`), под которым живёт этот экран как один из табов
        static let tabBarHeight: CGFloat = 96
    }
}
