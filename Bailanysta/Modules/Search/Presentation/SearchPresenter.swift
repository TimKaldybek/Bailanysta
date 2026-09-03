//
//  SearchPresenter.swift
//  Bailanysta
//

import Foundation

final class SearchPresenter {
    weak var view: SearchViewInput?

    private let interactor: SearchInteractor
    private let viewDataFactory: SearchViewDataFactory

    private var model = SearchModel(trendingTopics: [], suggestedUsers: [])
    private var recentSearches: [String]

    init(interactor: SearchInteractor, viewDataFactory: SearchViewDataFactory) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
        self.recentSearches = Constants.initialRecentSearches
    }

    // MARK: - Public

    func load() {
        Task { @MainActor in
            model = await interactor.loadData()
            pushViewData()
        }
    }

    func recordSearch(_ text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }

        recentSearches.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        recentSearches.insert(trimmed, at: 0)
        recentSearches = Array(recentSearches.prefix(Constants.recentSearchesLimit))

        pushViewData()
    }

    func clearRecentSearches() {
        recentSearches = []
        pushViewData()
    }

    func toggleFollow(userID: String) {
        guard let index = model.suggestedUsers.firstIndex(where: { $0.id == userID }) else { return }

        model.suggestedUsers[index].isFollowing.toggle()
        pushViewData()
    }
}

// MARK: - Private

private extension SearchPresenter {
    func pushViewData() {
        let viewData = viewDataFactory.createViewData(model: model, recentSearches: recentSearches)
        view?.display(viewData)
    }

    enum Constants {
        static let recentSearchesLimit = 5
        static let initialRecentSearches = ["UI Design Trends", "Dark Mode Best Practices", "Glassmorphism CSS"]
    }
}
