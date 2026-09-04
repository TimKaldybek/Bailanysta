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
    let isPostEnabled: Bool
    let isSubmitting: Bool
}

struct FeedPostCategoryViewData {
    let title: String
    let isSelected: Bool
}

struct FeedPostAttachmentViewData {
    let id: UUID
    let image: UIImage
}
