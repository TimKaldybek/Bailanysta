//
//  FeedViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class FeedViewController: UIViewController {

    var settingsButtonTapped: (() -> Void)?
    var composeButtonTapped: (() -> Void)?
    var postAuthorTapped: ((String) -> Void)?
    var commentsTapped: ((UUID) -> Void)?
    var shareTapped: ((String) -> Void)?
    /// Set only when this instance is pushed as a secondary screen (e.g. a Trending Searches
    /// topic's filtered feed) rather than shown as the Feed tab's root — shows a back chevron
    var backButtonTapped: (() -> Void)? {
        didSet { backButton.isHidden = backButtonTapped == nil }
    }

    private let presenter: FeedPresenter
    private let collectionView: UICollectionView

    /// `lazy`, а не `let`: замыкание захватывает `self`, что запрещено до вызова `super.init()`
    private lazy var dataSource = FeedDataSource(
        collectionView: collectionView,
        onAvatarTapped: { [weak self] viewData in
            self?.postAuthorTapped?(viewData.authorHandle)
        },
        onLikeTapped: { [weak self] postID in
            self?.presenter.likeTapped(postID: postID)
        },
        onCommentsTapped: { [weak self] postID in
            self?.commentsTapped?(postID)
        },
        onShareTapped: { [weak self] viewData in
            self?.shareTapped?(viewData.text)
        },
        onCardTapped: { [weak self] postID in
            self?.commentsTapped?(postID)
        }
    )

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface
        return view
    }()

    private let settingsButton = FeedViewController.makeHeaderButton(systemImageName: "gearshape.fill")
    private let backButton: UIButton = {
        let button = FeedViewController.makeHeaderButton(systemImageName: "chevron.left")
        button.isHidden = true
        return button
    }()

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
        dataSource.reload(items: viewData.items)
        composeView.configure(with: viewData.composer)

        if let errorMessage = viewData.errorMessage {
            showAlert(title: "Error".localized, message: errorMessage)
        }
    }

    func endRefreshing() {
        collectionView.refreshControl?.endRefreshing()
    }
}

// MARK: - UICollectionViewDelegate

extension FeedViewController: UICollectionViewDelegate {}

// MARK: - Private

private extension FeedViewController {

    func setupUI() {
        view.backgroundColor = Color.background

        [backButton, titleLabel, settingsButton].forEach { headerView.addSubview($0) }
        view.addSubview(headerView)
        view.addSubview(composeView)
        view.addSubview(collectionView)

        settingsButton.addAction(UIAction { [weak self] _ in
            self?.settingsButtonTapped?()
        }, for: .touchUpInside)

        backButton.addAction(UIAction { [weak self] _ in
            self?.backButtonTapped?()
        }, for: .touchUpInside)

        composeView.onComposeTapped = { [weak self] in
            self?.composeButtonTapped?()
        }

        let refreshControl = UIRefreshControl()
        refreshControl.addAction(UIAction { [weak self] _ in
            self?.presenter.refresh()
        }, for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalTo(settingsButton)
            $0.size.equalTo(32)
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
