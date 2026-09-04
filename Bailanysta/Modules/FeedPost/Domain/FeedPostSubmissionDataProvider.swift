//
//  FeedPostSubmissionDataProvider.swift
//  Bailanysta
//

import UIKit

struct FeedPostSubmissionDataProvider {
    private let service: FeedPostSubmissionService

    init(service: FeedPostSubmissionService) {
        self.service = service
    }

    func submit(_ draft: FeedPostDraft) async -> Bool {
        await service.submit(Self.map(draft))
    }

    private static func map(_ draft: FeedPostDraft) -> FeedPostSubmissionDTO {
        FeedPostSubmissionDTO(
            text: draft.text,
            category: draft.category.rawValue,
            attachments: draft.images.map(Self.map)
        )
    }

    private static func map(_ attachment: FeedPostAttachment) -> FeedPostAttachmentDTO {
        let data = attachment.image.jpegData(compressionQuality: Constants.jpegCompressionQuality) ?? Data()
        return FeedPostAttachmentDTO(
            fileName: "\(attachment.id.uuidString).jpg",
            mimeType: "image/jpeg",
            base64Data: data.base64EncodedString()
        )
    }
}

// MARK: - Constants

private extension FeedPostSubmissionDataProvider {
    enum Constants {
        static let jpegCompressionQuality: CGFloat = 0.8
    }
}
