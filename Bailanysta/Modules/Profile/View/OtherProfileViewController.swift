//
//  OtherProfileViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class OtherProfileViewController: UIViewController {

    var settingsButtonTapped: (() -> Void)?
    var backButtonTapped: (() -> Void)?

    private let presenter: OtherProfilePresenter
    private let collectionView: UICollectionView

    /// `lazy`, а не `let`: замыкание захватывает `self`, что запрещено до вызова `super.init()`.
    /// Переход "чужой профиль → тап на аватар поста → ещё один чужой профиль" вне скоупа задачи, поэтому колбэк — no-op
    private lazy var dataSource = OtherProfileDataSource(collectionView: collectionView, onAvatarTapped: { _ in })

    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = Color.surface
        return view
    }()

    private let settingsButton = OtherProfileViewController.makeHeaderButton(systemImageName: "gearshape.fill")
    private let backButton = OtherProfileViewController.makeHeaderButton(systemImageName: "chevron.left")

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.setText("Profile.AppName".localized, size: 28, weight: .bold, textColor: Color.primary)
        return label
    }()

    private let otherProfileHeaderCardView = OtherProfileHeaderCardView()

    // MARK: - Init

    init(presenter: OtherProfilePresenter) {
        self.presenter = presenter

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: OtherProfileLayout.make())
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
        navigationController?.interactivePopGestureRecognizer?.delegate = self
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
}

// MARK: - OtherProfileViewInput

extension OtherProfileViewController: OtherProfileViewInput {
    func display(_ viewData: OtherProfileViewData) {
        otherProfileHeaderCardView.configure(with: viewData.header, selectedTab: viewData.selectedTab, isLoading: viewData.isLoading)
        dataSource.reload(items: viewData.items)

        if let errorMessage = viewData.errorMessage {
            showAlert(title: "Error".localized, message: errorMessage)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension OtherProfileViewController: UICollectionViewDelegate {}

// MARK: - UIGestureRecognizerDelegate

extension OtherProfileViewController: UIGestureRecognizerDelegate {}

// MARK: - Private

private extension OtherProfileViewController {

    func setupUI() {
        view.backgroundColor = Color.background

        [backButton, titleLabel, settingsButton].forEach { headerView.addSubview($0) }
        view.addSubview(headerView)
        view.addSubview(otherProfileHeaderCardView)
        view.addSubview(collectionView)

        settingsButton.addAction(UIAction { [weak self] _ in
            self?.settingsButtonTapped?()
        }, for: .touchUpInside)

        backButton.addAction(UIAction { [weak self] _ in
            self?.backButtonTapped?()
        }, for: .touchUpInside)

        otherProfileHeaderCardView.onFollowTapped = { [weak self] in
            self?.presenter.toggleFollow()
        }
        otherProfileHeaderCardView.onMessageTapped = { [weak self] in
            self?.showComingSoonSheet()
        }
        otherProfileHeaderCardView.onTabSelected = { [weak self] tab in
            self?.presenter.selectTab(tab)
        }
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
            $0.leading.equalTo(backButton.snp.trailing).offset(8)
            $0.centerY.equalTo(settingsButton)
        }
        settingsButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(12)
            $0.size.equalTo(32)
        }
        otherProfileHeaderCardView.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(otherProfileHeaderCardView.snp.bottom).offset(12)
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
