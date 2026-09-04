//
//  SearchViewController.swift
//  Bailanysta
//

import UIKit
import SnapKit

final class SearchViewController: UIViewController {

    /// Тап по фото/имени/логину в блоке "Suggested for you" — открывает профиль по хэндлу
    var suggestedUserTapped: ((String) -> Void)?
    /// Тап по карточке в блоке "Trending" — открывает Feed, предзагруженный постами по теме
    var trendingTopicTapped: ((String) -> Void)?
    /// Сабмит поискового запроса (return в поле поиска или тап по chip'у истории) — открывает Feed,
    /// отфильтрованный по ключевому слову/хэштегу
    var searchSubmitted: ((String) -> Void)?

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
    private let popularHashtagsView = PopularHashtagsView()

    /// Stacks the collapsible Recent Searches / Popular Hashtags blocks above `collectionView` —
    /// hiding an arranged subview via `isHidden` collapses its space automatically, so any number
    /// of these blocks can appear/disappear without remaking `collectionView`'s constraints
    private let collapsibleBlocksStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 20
        return stack
    }()

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
            self?.submitSearch(text)
        }
        searchBarView.onMicTapped = { [weak self] in
            self?.showComingSoonSheet()
        }
        recentSearchesView.onClearTapped = { [weak self] in
            self?.presenter.clearRecentSearches()
        }
        recentSearchesView.onChipTapped = { [weak self] text in
            self?.searchBarView.setText(text)
            self?.submitSearch(text)
        }
        popularHashtagsView.onChipTapped = { [weak self] tag in
            self?.searchBarView.setText(tag)
            self?.submitSearch(tag)
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
        recentSearchesView.isHidden = viewData.recentSearches.isEmpty

        popularHashtagsView.configure(items: viewData.popularHashtags)
        popularHashtagsView.isHidden = viewData.popularHashtags.isEmpty

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
        case .trending(let viewData):
            trendingTopicTapped?(viewData.category)
        case .suggestedUser:
            // Профиль/фоллоу обрабатываются собственными тап-таргетами `SuggestedUserCell`, а не
            // выбором ячейки целиком
            break
        }
    }
}

// MARK: - Private

private extension SearchViewController {
    func submitSearch(_ text: String) {
        switch presenter.recordSearch(text) {
        case .empty:
            break
        case .searched(let query):
            searchSubmitted?(query)
        }
    }

    func setupUI() {
        view.backgroundColor = Color.background
        [recentSearchesView, popularHashtagsView].forEach { collapsibleBlocksStack.addArrangedSubview($0) }
        [searchBarView, collapsibleBlocksStack, collectionView].forEach { view.addSubview($0) }
    }

    func setupConstraints() {
        searchBarView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        collapsibleBlocksStack.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(collapsibleBlocksStack.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        collectionView.contentInset.bottom = Constants.tabBarHeight
    }

    enum Constants {
        /// Высота реального таб-бара (`TabBarView`), под которым живёт этот экран как один из табов
        static let tabBarHeight: CGFloat = 96
    }
}
