//
//  FeedPostSubmissionDTO.swift
//  Bailanysta
//

import Foundation

struct FeedPostSubmissionDTO {
    let text: String
    let category: String
    let attachments: [FeedPostAttachmentDTO]
    let voiceMessage: FeedPostVoiceMessageDTO?
}

struct FeedPostAttachmentDTO {
    let fileName: String
    let imageData: Data
}

struct FeedPostVoiceMessageDTO {
    let fileName: String
    let audioData: Data
    let duration: TimeInterval
}
