//
//  FeedPostPresenter.swift
//  Bailanysta
//

final class FeedPostPresenter {
    weak var view: FeedPostViewInput?

    private let interactor: FeedPostInteractor
    private let viewDataFactory: FeedPostFormViewDataFactory

    private var draft = FeedPostDraft(text: "", category: .design)

    init(interactor: FeedPostInteractor, viewDataFactory: FeedPostFormViewDataFactory) {
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    func load() {
        pushViewData()
    }

    func textChanged(_ text: String) {
        draft.text = text
        pushViewData()
    }

    func categoryTapped(at index: Int) {
        guard FeedPostCategory.allCases.indices.contains(index) else { return }

        draft.category = FeedPostCategory.allCases[index]
        pushViewData()
    }

    func postButtonTapped() {
        Task { @MainActor in
            let success = await interactor.submit(draft)
            if success {
                view?.closeAfterPosting()
            }
        }
    }
}

// MARK: - Private

private extension FeedPostPresenter {
    func pushViewData() {
        let viewData = viewDataFactory.createViewData(draft)
        view?.display(viewData)
    }
}
