//
//  FeedPostPresenter.swift
//  Bailanysta
//

import UIKit

final class FeedPostPresenter {
    weak var view: FeedPostViewInput?

    private let interactor: FeedPostInteractor
    private let viewDataFactory: FeedPostFormViewDataFactory

    private var draft = FeedPostDraft(text: "", category: .design, images: [])
    private var isSubmitting = false

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

    func imagesPicked(_ images: [UIImage]) {
        let availableSlots = FeedPostFormViewDataFactory.Constants.maxAttachments - draft.images.count
        guard availableSlots > 0 else { return }

        let newAttachments = images.prefix(availableSlots).map { FeedPostAttachment(image: $0) }
        draft.images.append(contentsOf: newAttachments)
        pushViewData()
    }

    func removeAttachment(at index: Int) {
        guard draft.images.indices.contains(index) else { return }

        draft.images.remove(at: index)
        pushViewData()
    }

    func postButtonTapped() {
        guard !isSubmitting, isTextValid else { return }

        isSubmitting = true
        pushViewData()

        Task { @MainActor in
            do {
                try await interactor.submit(draft)
                isSubmitting = false
                view?.closeAfterPosting()
            } catch {
                isSubmitting = false
                pushViewData(errorMessage: "FeedPost.Error.Generic".localized)
            }
        }
    }
}

// MARK: - Private

private extension FeedPostPresenter {
    var isTextValid: Bool {
        !draft.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func pushViewData(errorMessage: String? = nil) {
        let viewData = viewDataFactory.createViewData(draft, isSubmitting: isSubmitting, errorMessage: errorMessage)
        view?.display(viewData)
    }
}
