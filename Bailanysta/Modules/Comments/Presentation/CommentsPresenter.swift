//
//  CommentsPresenter.swift
//  Bailanysta
//

import Foundation

final class CommentsPresenter {
    weak var view: CommentsViewInput?

    private let postID: UUID
    private let interactor: CommentsInteractor
    private let viewDataFactory: CommentsViewDataFactory

    private var comments: [Comment] = []
    private var isSubmitting = false

    init(postID: UUID, interactor: CommentsInteractor, viewDataFactory: CommentsViewDataFactory) {
        self.postID = postID
        self.interactor = interactor
        self.viewDataFactory = viewDataFactory
    }

    // MARK: - Public

    func load() {
        Task { @MainActor in
            comments = await interactor.loadData(postID: postID)
            pushViewData()
        }
    }

    func submitComment(text: String) {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !isSubmitting else { return }

        isSubmitting = true
        view?.setComposerEnabled(false)

        Task { @MainActor in
            defer {
                isSubmitting = false
                view?.setComposerEnabled(true)
            }

            guard let newComment = await interactor.addComment(postID: postID, text: trimmed) else { return }

            comments.append(newComment)
            pushViewData()
            view?.clearComposerInput()
        }
    }
}

// MARK: - Private

private extension CommentsPresenter {
    func pushViewData() {
        view?.display(viewDataFactory.createViewData(comments: comments))
    }
}
