//
//  ProfileInteractor.swift
//  Bailanysta
//

import Foundation

final class ProfileInteractor {
    private let dataProvider: ProfileDataProvider

    init(dataProvider: ProfileDataProvider) {
        self.dataProvider = dataProvider
    }

    func loadData() async throws -> ProfileModel {
        try await dataProvider.loadData()
    }

    func uploadAvatar(imageData: Data) async throws {
        try await dataProvider.uploadAvatar(imageData: imageData)
    }

    func deletePost(postID: String) async throws {
        try await dataProvider.deletePost(postID: postID)
    }

    func deleteReply(postID: String, commentID: String) async throws {
        try await dataProvider.deleteReply(postID: postID, commentID: commentID)
    }
}
