//
//  OtherProfileUser.swift
//  Bailanysta
//

import Foundation

struct OtherProfileUser: Hashable {
    let id: UUID
    let name: String
    let handle: String
    let tagline: String
    let avatarImageName: String
    let followersCount: Int
    let followingCount: Int
    let postsCount: Int
    /// `var`, а не `let`: презентер переключает состояние локально по тапу на кнопку Follow
    var isFollowing: Bool
}
