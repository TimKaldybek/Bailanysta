//
//  FeedPresenter.swift
//  Bailanysta
//

import Foundation

final class FeedPresenter {
    weak var view: FeedViewInput?

    private let interactor: FeedInteractor
    private let viewDataFactory: FeedViewDataFactory

    private var posts: [FeedPost] = []
    private var likeRequestsInFlight: Set<UUID> = []

    init(interactor: FeedInteractor, viewDataFactory: FeedViewDataFactory) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    func load() {
        Task { @MainActor in
            posts = await interactor.loadData()
            pushViewData()
        }
    }

    func likeTapped(postID: UUID) {
        guard likeRequestsInFlight.insert(postID).inserted else { return }

        Task { @MainActor in
            defer { likeRequestsInFlight.remove(postID) }

            guard let updated = await interactor.toggleLike(postID: postID),
                  let index = posts.firstIndex(where: { $0.id == postID }) else { return }

            posts[index] = updated
            pushViewData()
        }
    }
}

// MARK: - Private

private extension FeedPresenter {
    func pushViewData() {
        let viewData = viewDataFactory.createViewData(posts: posts)
        view?.display(viewData)
    }
}
