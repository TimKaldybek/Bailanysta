//
//  FeedPresenter.swift
//  Bailanysta
//

import Foundation

final class FeedPresenter {
    weak var view: FeedViewInput?

    private let interactor: FeedInteractor
    private let viewDataFactory: FeedViewDataFactory
    /// Фильтр, полученный от Trending Searches или поиска; `nil` — обычная непрефильтрованная лента
    private let filter: FeedFilter?

    private var posts: [FeedPost] = []
    private var composer = FeedComposer(name: "", avatarImageName: "person.crop.circle.fill", avatarURL: nil)
    private var likeRequestsInFlight: Set<UUID> = []
    /// `true` until the first page of posts (success or failure) has arrived — shows the feed's
    /// skeleton state until then.
    private var isLoading = true

    /// Guards against starting a second live listener — `load()` may be called more than once
    /// (e.g. repeated `viewDidLoad`s aren't expected, but this keeps the guarantee explicit).
    private var observeTask: Task<Void, Never>?

    init(interactor: FeedInteractor, viewDataFactory: FeedViewDataFactory, filter: FeedFilter? = nil) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
        self.filter = filter
    }

    // MARK: - Public

      func load() {
        loadComposer()
        pushViewData()

        guard observeTask == nil else { return }
        observeTask = Task { @MainActor [weak self] in
            guard let self else { return }
            for await result in interactor.observePosts(filter: filter) {
                isLoading = false
                switch result {
                case .success(let posts):
                    self.posts = posts
                    pushViewData()
                case .failure:
                    pushViewData(errorMessage: "Feed.Error.Load".localized)
                }
            }
        }
    }

    func refresh() {
        Task { @MainActor in
            do {
                posts = try await interactor.loadData(filter: filter)
                pushViewData()
            } catch {
                pushViewData(errorMessage: "Feed.Error.Load".localized)
            }
            view?.endRefreshing()
        }
    }

    func likeTapped(postID: UUID) {
        guard likeRequestsInFlight.insert(postID).inserted else { return }
        guard let index = posts.firstIndex(where: { $0.id == postID }) else {
            likeRequestsInFlight.remove(postID)
            return
        }
        let isLiked = posts[index].isLiked

        Task { @MainActor in
            defer { likeRequestsInFlight.remove(postID) }

            do {
                let updated = try await interactor.toggleLike(postID: postID, isLiked: isLiked)
                guard let index = posts.firstIndex(where: { $0.id == postID }) else { return }
                posts[index] = updated
                pushViewData()
            } catch {
                pushViewData(errorMessage: "Feed.Error.Like".localized)
            }
        }
    }
}

// MARK: - Private

private extension FeedPresenter {
    /// One-shot load — the compose bar's avatar doesn't need live-reactivity, unlike the posts list.
    func loadComposer() {
        Task { @MainActor in
            do {
                composer = try await interactor.loadComposer()
                pushViewData()
            } catch {
                // A failed composer read isn't user-facing — the compose bar just keeps its
                // default placeholder avatar.
            }
        }
    }

    func pushViewData(errorMessage: String? = nil) {
        let viewData = viewDataFactory.createViewData(
            posts: posts,
            composer: composer,
            isLoading: isLoading,
            errorMessage: errorMessage
        )
        view?.display(viewData)
    }
}
