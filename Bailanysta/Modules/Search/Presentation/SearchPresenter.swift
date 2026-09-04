//
//  SearchPresenter.swift
//  Bailanysta
//

import Foundation

/// Outcome of `SearchPresenter.recordSearch(_:)`, returned synchronously so the ViewController can
/// decide whether to trigger navigation (the Presenter never navigates itself).
enum SearchSubmitResult {
    case empty
    case searched(String)
}

final class SearchPresenter {
    weak var view: SearchViewInput?

    private let interactor: SearchInteractor
    private let viewDataFactory: SearchViewDataFactory

    private var model = SearchModel(trendingTopics: [], suggestedUsers: [], popularHashtags: [])
    private var recentSearches: [String]

    init(interactor: SearchInteractor, viewDataFactory: SearchViewDataFactory) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
        self.recentSearches = Constants.initialRecentSearches
    }

    // MARK: - Public

    func load() {
        Task { @MainActor in
            do {
                model = try await interactor.loadData()
                pushViewData()
            } catch {
                pushViewData(errorMessage: "Search.Error.Load".localized)
            }
        }
    }

    @discardableResult
    func recordSearch(_ text: String) -> SearchSubmitResult {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return .empty }

        recentSearches.removeAll { $0.caseInsensitiveCompare(trimmed) == .orderedSame }
        recentSearches.insert(trimmed, at: 0)
        recentSearches = Array(recentSearches.prefix(Constants.recentSearchesLimit))

        pushViewData()
        return .searched(trimmed)
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
    func pushViewData(errorMessage: String? = nil) {
        let viewData = viewDataFactory.createViewData(
            model: model,
            recentSearches: recentSearches,
            errorMessage: errorMessage
        )
        view?.display(viewData)
    }

    enum Constants {
        static let recentSearchesLimit = 5
        static let initialRecentSearches = ["UI Design Trends", "Dark Mode Best Practices", "Glassmorphism CSS"]
    }
}
