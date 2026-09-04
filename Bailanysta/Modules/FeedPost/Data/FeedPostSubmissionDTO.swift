//
//  FeedPostSubmissionDTO.swift
//  Bailanysta
//

struct FeedPostSubmissionDTO {
    let text: String
    let category: String
    let attachments: [FeedPostAttachmentDTO]
}

struct FeedPostAttachmentDTO {
    let fileName: String
    let mimeType: String
    let base64Data: String
}
