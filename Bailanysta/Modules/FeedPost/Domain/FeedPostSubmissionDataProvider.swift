//
//  FeedPostSubmissionDataProvider.swift
//  Bailanysta
//

struct FeedPostSubmissionDataProvider {
    private let service: FeedPostSubmissionService

    init(service: FeedPostSubmissionService) {
        self.service = service
    }

    func submit(_ draft: FeedPostDraft) async -> Bool {
        await service.submit(Self.map(draft))
    }

    private static func map(_ draft: FeedPostDraft) -> FeedPostSubmissionDTO {
        FeedPostSubmissionDTO(text: draft.text, category: draft.category.rawValue)
    }
}
