//
//  FeedPostInteractor.swift
//  Bailanysta
//

final class FeedPostInteractor {
    private let dataProvider: FeedPostSubmissionDataProvider

    init(dataProvider: FeedPostSubmissionDataProvider) {
        self.dataProvider = dataProvider
    }

    func submit(_ draft: FeedPostDraft) async -> Bool {
        await dataProvider.submit(draft)
    }
}
