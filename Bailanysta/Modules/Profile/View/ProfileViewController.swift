//
//  ProfileViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit
import PhotosUI

final class ProfileViewController: UIViewController {

    var settingsButtonTapped: (() -> Void)?
    var shareTapped: ((String) -> Void)?
    var postAuthorTapped: ((String) -> Void)?
    var commentsTapped: ((UUID) -> Void)?

    private let presenter: ProfilePresenter
    private lazy var dataSource: ProfileDataSource = ProfileDataSource(
        collectionView: collectionView,
        onEditProfileTapped: { [weak self] in
            self?.presentAvatarPicker()
        },
        onShareTapped: { [weak self] handle in
            self?.shareTapped?(handle)
        },
        onTabSelected: { [weak presenter] tab in
            presenter?.selectTab(tab)
        },
        onAvatarTapped: { [weak self] viewData in
            self?.postAuthorTapped?(viewData.authorHandle)
        },
        onCommentsTapped: { [weak self] postID in
            self?.commentsTapped?(postID)
        },
        onComingSoonEngagementTapped: { [weak self] in
            self?.showComingSoonSheet()
        }
    )
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
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        presenter.load()
    }
}

// MARK: - ProfileViewInput

extension ProfileViewController: ProfileViewInput {
    func display(_ viewData: ProfileViewData) {
        dataSource.reload(viewData)

        if let errorMessage = viewData.errorMessage {
            showAlert(title: "Error".localized, message: errorMessage)
        }
    }

    func endRefreshing() {
        collectionView.refreshControl?.endRefreshing()
    }
}

// MARK: - UICollectionViewDelegate

extension ProfileViewController: UICollectionViewDelegate {}

// MARK: - PHPickerViewControllerDelegate

extension ProfileViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard let result = results.first else { return }

        Task { @MainActor in
            guard let image = await Self.loadImage(from: result),
                  let imageData = image.jpegData(compressionQuality: Constants.jpegCompressionQuality) else { return }
            presenter.avatarPicked(imageData)
        }
    }
}

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

    func presentAvatarPicker() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.filter = .images
        configuration.selectionLimit = 1

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = self
        present(picker, animated: true)
    }

    static func loadImage(from result: PHPickerResult) async -> UIImage? {
        await withCheckedContinuation { continuation in
            guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                continuation.resume(returning: nil)
                return
            }
            result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                continuation.resume(returning: object as? UIImage)
            }
        }
    }

    enum Constants {
        /// Высота реального таб-бара (`TabBarView`), под которым живёт этот экран как один из табов
        static let tabBarHeight: CGFloat = 96
        static let jpegCompressionQuality: CGFloat = 0.8
    }
}
