//
//  FeedPostSubmissionDTO.swift
//  Bailanysta
//

import Foundation

struct FeedPostSubmissionDTO {
    let text: String
    let category: String
    let attachments: [FeedPostAttachmentDTO]
}

struct FeedPostAttachmentDTO {
    let fileName: String
    let imageData: Data
}
