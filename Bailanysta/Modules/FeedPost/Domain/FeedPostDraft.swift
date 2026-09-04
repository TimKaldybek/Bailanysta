//
//  FeedPostDraft.swift
//  Bailanysta
//

import UIKit

struct FeedPostDraft {
    var text: String
    var category: FeedPostCategory
    var images: [FeedPostAttachment]
    var voiceMessage: FeedPostVoiceMessage?
}

struct FeedPostAttachment {
    let id: UUID
    let image: UIImage

    init(id: UUID = UUID(), image: UIImage) {
        self.id = id
        self.image = image
    }
}

/// A freshly recorded, not-yet-uploaded voice message — `fileURL` points at a local temp file
/// (`.m4a`) produced by `AVAudioRecorder` in `FeedPostViewController`.
struct FeedPostVoiceMessage {
    let fileURL: URL
    let duration: TimeInterval
}
