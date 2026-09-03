//
//  FeedPresenter.swift
//  Bailanysta
//

final class FeedPresenter {
    weak var view: FeedViewInput?

    private let interactor: FeedInteractor
    private let viewDataFactory: FeedViewDataFactory

    private var posts: [FeedPost] = []

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
}

// MARK: - Private

private extension FeedPresenter {
    func pushViewData() {
        let viewData = viewDataFactory.createViewData(posts: posts)
        view?.display(viewData)
    }
}
