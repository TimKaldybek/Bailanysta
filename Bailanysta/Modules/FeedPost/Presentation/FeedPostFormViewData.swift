//
//  FeedPostFormViewData.swift
//  Bailanysta
//

import UIKit

struct FeedPostFormViewData {
    let categories: [FeedPostCategoryViewData]
    let attachments: [FeedPostAttachmentViewData]
    let characterCountText: String
    let isCharacterCountNearLimit: Bool
    let maxCharacterCount: Int
    let attachmentsCountText: String
    let isAddPhotoEnabled: Bool
    let remainingAttachmentSlots: Int
    let voiceMessage: FeedPostVoiceMessageViewData?
    let isRecordVoiceEnabled: Bool
    let isPostEnabled: Bool
    let isSubmitting: Bool
    let errorMessage: String?
}

struct FeedPostCategoryViewData {
    let title: String
    let isSelected: Bool
}

struct FeedPostAttachmentViewData {
    let id: UUID
    let image: UIImage
}

struct FeedPostVoiceMessageViewData {
    let fileURL: URL
    let duration: TimeInterval
}
