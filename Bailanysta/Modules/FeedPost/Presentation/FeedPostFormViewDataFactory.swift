//
//  FeedPostFormViewDataFactory.swift
//  Bailanysta
//

import Foundation

struct FeedPostFormViewDataFactory {
    func createViewData(_ draft: FeedPostDraft, isSubmitting: Bool, errorMessage: String? = nil) -> FeedPostFormViewData {
        let categories = FeedPostCategory.allCases.map { category in
            FeedPostCategoryViewData(
                title: Self.title(for: category),
                isSelected: category == draft.category
            )
        }

        let attachments = draft.images.map {
            FeedPostAttachmentViewData(id: $0.id, image: $0.image)
        }

        let remainingCharacters = Constants.maxCharacterCount - draft.text.count
        let remainingAttachmentSlots = max(0, Constants.maxAttachments - draft.images.count)
        let trimmedText = draft.text.trimmingCharacters(in: .whitespacesAndNewlines)
        let voiceMessage = draft.voiceMessage.map {
            FeedPostVoiceMessageViewData(fileURL: $0.fileURL, duration: $0.duration)
        }

        return FeedPostFormViewData(
            categories: categories,
            attachments: attachments,
            characterCountText: "\(draft.text.count)/\(Constants.maxCharacterCount)",
            isCharacterCountNearLimit: remainingCharacters <= Constants.nearLimitThreshold,
            maxCharacterCount: Constants.maxCharacterCount,
            attachmentsCountText: "\(draft.images.count)/\(Constants.maxAttachments)",
            isAddPhotoEnabled: !isSubmitting && remainingAttachmentSlots > 0,
            remainingAttachmentSlots: remainingAttachmentSlots,
            voiceMessage: voiceMessage,
            isRecordVoiceEnabled: !isSubmitting && draft.voiceMessage == nil,
            isPostEnabled: !isSubmitting && (!trimmedText.isEmpty || draft.voiceMessage != nil),
            isSubmitting: isSubmitting,
            errorMessage: errorMessage
        )
    }

    private static func title(for category: FeedPostCategory) -> String {
        switch category {
        case .design:
            return "FeedPost.Category.Design".localized
        case .tech:
            return "FeedPost.Category.Tech".localized
        case .updates:
            return "FeedPost.Category.Updates".localized
        case .general:
            return "FeedPost.Category.General".localized
        }
    }
}

// MARK: - Constants

extension FeedPostFormViewDataFactory {
    enum Constants {
        static let maxCharacterCount = 500
        static let maxAttachments = 4
        static let nearLimitThreshold = 20
    }
}
