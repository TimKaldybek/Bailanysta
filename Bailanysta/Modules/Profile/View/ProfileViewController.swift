//
//  ProfileViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    var settingsButtonTapped: (() -> Void)?
    /// Пока не подключён координатором — экрана редактирования профиля в приложении ещё нет
    var editProfileTapped: (() -> Void)?
    var shareTapped: ((String) -> Void)?
    var postAuthorTapped: ((String) -> Void)?

    private let presenter: ProfilePresenter
    private let collectionView: UICollectionView

    /// `lazy`, а не `let`: замыкание захватывает `self`, что запрещено до вызова `super.init()`
    private lazy var dataSource = ProfileDataSource(collectionView: collectionView, onAvatarTapped: { [weak self] viewData in
        self?.postAuthorTapped?(viewData.authorHandle)
    })

    private var shareHandle = ""

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface
        return view
    }()

    private let settingsButton = ProfileViewController.makeHeaderButton(systemImageName: "gearshape.fill")

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("Profile.Title".localized, size: 28, weight: .bold, textColor: Color.primary)
        return label
    }()

    private let profileHeaderCardView = ProfileHeaderCardView()

    // MARK: - Init

    init(presenter: ProfilePresenter) {
        self.presenter = presenter

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ProfileLayout.make())
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

// MARK: - ProfileViewInput

extension ProfileViewController: ProfileViewInput {
    func display(_ viewData: ProfileViewData) {
        shareHandle = viewData.header.handle
        profileHeaderCardView.configure(with: viewData.header, selectedTab: viewData.selectedTab)
        dataSource.reload(items: viewData.items)
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {}

// MARK: - Private

private extension ProfileViewController {

    func setupUI() {
        view.backgroundColor = Color.background

        [titleLabel, settingsButton].forEach { headerView.addSubview($0) }
        view.addSubview(headerView)
        view.addSubview(profileHeaderCardView)
        view.addSubview(collectionView)

        settingsButton.addAction(UIAction { [weak self] _ in
            self?.settingsButtonTapped?()
        }, for: .touchUpInside)

        profileHeaderCardView.onEditProfileTapped = { [weak self] in
            self?.editProfileTapped?()
        }
        profileHeaderCardView.onShareTapped = { [weak self] in
            guard let self else { return }
            self.shareTapped?(self.shareHandle)
        }
        profileHeaderCardView.onTabSelected = { [weak self] tab in
            self?.presenter.selectTab(tab)
        }
    }

    func setupConstraints() {
        headerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.top).offset(56)
        }
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalTo(settingsButton)
        }
        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
            $0.size.equalTo(32)
        }
        profileHeaderCardView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(profileHeaderCardView.snp.bottom).offset(12)
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
