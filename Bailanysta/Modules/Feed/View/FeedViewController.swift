//
//  FeedViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class FeedViewController: UIViewController {

    var settingsButtonTapped: (() -> Void)?
    var composeButtonTapped: (() -> Void)?

    private let presenter: FeedPresenter
    private let dataSource: FeedDataSource
    private let collectionView: UICollectionView

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface
        return view
    }()

    private let settingsButton = FeedViewController.makeHeaderButton(systemImageName: "gearshape.fill")

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("Feed.AppName".localized, size: 28, weight: .bold, textColor: Color.primary)
        return label
    }()

    private let composeView = FeedComposeView()

    // MARK: - Init

    init(presenter: FeedPresenter) {
        self.presenter = presenter

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: FeedLayout.make())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        self.collectionView = collectionView
        self.dataSource = FeedDataSource(collectionView: collectionView)

        super.init(nibName: nil, bundle: nil)

        collectionView.delegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupConstraints()
        presenter.load()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}

// MARK: - FeedViewInput

extension FeedViewController: FeedViewInput {
    func display(_ viewData: FeedViewData) {
        dataSource.reload(posts: viewData.posts)
    }
}

// MARK: - UICollectionViewDelegate

extension FeedViewController: UICollectionViewDelegate {}

// MARK: - Private

private extension FeedViewController {

    func setupUI() {
        view.backgroundColor = Color.background

        [titleLabel, settingsButton].forEach { headerView.addSubview($0) }
        view.addSubview(headerView)
        view.addSubview(composeView)
        view.addSubview(collectionView)

        settingsButton.addAction(UIAction { [weak self] _ in
            self?.settingsButtonTapped?()
        }, for: .touchUpInside)

        composeView.onComposeTapped = { [weak self] in
            self?.composeButtonTapped?()
        }
    }

    func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(settingsButton)
        }
        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
            $0.size.equalTo(32)
        }
        composeView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(composeView.snp.bottom).offset(12)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        collectionView.contentInset.bottom = Constants.tabBarHeight
    }

    static func makeHeaderButton(systemImageName: String) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: systemImageName), for: .normal)
        button.tintColor = Color.primary
        return button
    }

    enum Constants {
        /// Высота реального таб-бара (`TabBarView`), под которым живёт этот экран как один из табов
        static let tabBarHeight: CGFloat = 96
    }
}
