//
//  FeedPostDraft.swift
//  Bailanysta
//

import UIKit

struct FeedPostDraft {
    var text: String
    var category: FeedPostCategory
    var images: [FeedPostAttachment]
}

struct FeedPostAttachment {
    let id: UUID
    let image: UIImage

    init(id: UUID = UUID(), image: UIImage) {
        self.id = id
        self.image = image
    }
}
