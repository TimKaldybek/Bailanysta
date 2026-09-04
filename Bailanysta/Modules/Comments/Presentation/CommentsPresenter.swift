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
            do {
                comments = try await interactor.loadData(postID: postID)
                pushViewData()
            } catch {
                // A genuine read failure is a no-op against `comments` — keep the last-known-good
                // list (or the empty state) on screen instead of crashing.
                pushViewData(errorMessage: "Comments.Error.Load".localized)
            }
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

            do {
                let newComment = try await interactor.addComment(postID: postID, text: trimmed)
                comments.append(newComment)
                pushViewData()
                view?.clearComposerInput()
            } catch {
                // Don't lose the user's typed text on a failed send — the composer keeps its input.
                pushViewData(errorMessage: "Comments.Error.Send".localized)
            }
        }
    }
}

// MARK: - Private

private extension CommentsPresenter {
    func pushViewData(errorMessage: String? = nil) {
        view?.display(viewDataFactory.createViewData(comments: comments, errorMessage: errorMessage))
    }
}
