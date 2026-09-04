//
//  ProfileViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class ProfileViewController: UIViewController {

    var settingsButtonTapped: (() -> Void)?
    var editProfileTapped: (() -> Void)?
    var shareTapped: ((String) -> Void)?

    private let presenter: ProfilePresenter
    private let dataSource: ProfileDataSource
    private let collectionView: UICollectionView

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

    // MARK: - Init

    init(presenter: ProfilePresenter) {
        self.presenter = presenter

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: ProfileLayout.make())
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        self.collectionView = collectionView
        self.dataSource = ProfileDataSource(
            collectionView: collectionView,
            onEditProfileTapped: { [weak self] in
                self?.editProfileTapped?()
            },
            onShareTapped: { [weak self] handle in
                self?.shareTapped?(handle)
            },
            onTabSelected: { [weak presenter] tab in
                presenter?.selectTab(tab)
            }
        )

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
        dataSource.reload(viewData)
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
        view.addSubview(collectionView)

        settingsButton.addAction(UIAction { [weak self] _ in
            self?.settingsButtonTapped?()
        }, for: .touchUpInside)
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
        collectionView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
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
