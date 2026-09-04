//
//  FeedComposerDataProvider.swift
//  Bailanysta
//

import Foundation

struct FeedComposerDataProvider {
    private let service: FeedComposerService

    init(service: FeedComposerService) {
        self.service = service
    }

    func loadData() async throws -> FeedComposer {
        let dto = try await service.loadData()
        return Self.map(dto)
    }

    private static func map(_ dto: FeedComposerDTO) -> FeedComposer {
        FeedComposer(
            name: dto.name,
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: dto.avatarURL.flatMap(URL.init(string:))
        )
    }
}

// MARK: - Constants

private extension FeedComposerDataProvider {
    enum Constants {
        static let defaultAvatarImageName = "person.crop.circle.fill"
    }
}
