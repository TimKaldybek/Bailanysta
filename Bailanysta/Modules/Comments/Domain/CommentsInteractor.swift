//
//  CommentsInteractor.swift
//  Bailanysta
//

import Foundation

final class CommentsInteractor {
    private let dataProvider: CommentsDataProvider
    private let addCommentDataProvider: AddCommentDataProvider

    init(dataProvider: CommentsDataProvider, addCommentDataProvider: AddCommentDataProvider) {
        self.dataProvider = dataProvider
        self.addCommentDataProvider = addCommentDataProvider
    }

    func loadData(postID: UUID) async -> [Comment] {
        await dataProvider.loadData(postID: postID)
    }

    func addComment(postID: UUID, text: String) async -> Comment? {
        await addCommentDataProvider.addComment(postID: postID, text: text)
    }
}
