//
//  FeedComposer.swift
//  Bailanysta
//

import Foundation

/// The signed-in user's identity as shown in the Feed's compose bar.
struct FeedComposer {
    let name: String
    let avatarImageName: String
    let avatarURL: URL?
}
