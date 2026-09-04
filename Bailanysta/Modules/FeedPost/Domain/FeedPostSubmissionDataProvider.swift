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

    func submit(_ draft: FeedPostDraft) async throws {
        try await service.submit(Self.map(draft))
    }

    private static func map(_ draft: FeedPostDraft) throws -> FeedPostSubmissionDTO {
        FeedPostSubmissionDTO(
            text: draft.text,
            category: draft.category.rawValue,
            attachments: draft.images.map(Self.map),
            voiceMessage: try draft.voiceMessage.map(Self.map)
        )
    }

    private static func map(_ attachment: FeedPostAttachment) -> FeedPostAttachmentDTO {
        let data = attachment.image.jpegData(compressionQuality: Constants.jpegCompressionQuality) ?? Data()
        return FeedPostAttachmentDTO(fileName: "\(attachment.id.uuidString).jpg", imageData: data)
    }

    /// Reads the recorded `.m4a` back off disk — `FeedPostViewController` only hands the presenter
    /// a local file URL, not the audio bytes themselves.
    private static func map(_ voiceMessage: FeedPostVoiceMessage) throws -> FeedPostVoiceMessageDTO {
        let data = try Data(contentsOf: voiceMessage.fileURL)
        return FeedPostVoiceMessageDTO(
            fileName: "\(UUID().uuidString).m4a",
            audioData: data,
            duration: voiceMessage.duration
        )
    }
}

// MARK: - Constants

private extension FeedPostSubmissionDataProvider {
    enum Constants {
        static let jpegCompressionQuality: CGFloat = 0.8
    }
}
