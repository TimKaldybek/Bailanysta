//
//  SearchViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class SearchViewController: UIViewController {

    /// Тап по фото/имени/логину в блоке "Suggested for you" — открывает профиль по хэндлу
    var suggestedUserTapped: ((String) -> Void)?

    private let presenter: SearchPresenter
    private let collectionView: UICollectionView

    /// `lazy`, а не `let`: замыкания захватывают `self`, что запрещено до вызова `super.init()`
    private lazy var dataSource = SearchDataSource(
        collectionView: collectionView,
        onSuggestedUserProfileTapped: { [weak self] viewData in
            self?.suggestedUserTapped?(viewData.handle)
        },
        onSuggestedUserFollowTapped: { [weak self] viewData in
            self?.presenter.toggleFollow(userID: viewData.id)
        }
    )

    private let searchBarView = SearchBarView()
    private let recentSearchesView = RecentSearchesView()

    // MARK: - Init

    init(presenter: SearchPresenter) {
        self.presenter = presenter

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: SearchLayout.make())
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
        navigationController?.setNavigationBarHidden(true, animated: false)

        setupUI()
        setupConstraints()

        searchBarView.onSubmit = { [weak self] text in
            self?.presenter.recordSearch(text)
        }
        searchBarView.onMicTapped = { [weak self] in
            self?.showComingSoonSheet()
        }
        recentSearchesView.onClearTapped = { [weak self] in
            self?.presenter.clearRecentSearches()
        }
        recentSearchesView.onChipTapped = { [weak self] text in
            self?.searchBarView.setText(text)
        }
        presenter.load()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - SearchViewInput

extension SearchViewController: SearchViewInput {
    func display(_ viewData: SearchViewData) {
        recentSearchesView.configure(items: viewData.recentSearches)
        dataSource.reload(trendingTopics: viewData.trendingTopics, suggestedUsers: viewData.suggestedUsers)

        if let errorMessage = viewData.errorMessage {
            showAlert(title: "Error".localized, message: errorMessage)
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return }

        switch item {
        case .trending:
            showComingSoonSheet()
        case .suggestedUser:
            // Профиль/фоллоу обрабатываются собственными тап-таргетами `SuggestedUserCell`, а не
            // выбором ячейки целиком
            break
        }
    }
}

// MARK: - Private

private extension SearchViewController {
    func setupUI() {
        view.backgroundColor = Color.background
        [searchBarView, recentSearchesView, collectionView].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        searchBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        recentSearchesView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(recentSearchesView.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        collectionView.contentInset.bottom = Constants.tabBarHeight
    }

    enum Constants {
        /// Высота реального таб-бара (`TabBarView`), под которым живёт этот экран как один из табов
        static let tabBarHeight: CGFloat = 96
    }
}
