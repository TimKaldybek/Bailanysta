//
//  ProfileUser.swift
//  Bailanysta
//

import Foundation

struct ProfileUser: Hashable {
    let id: UUID
    let name: String
    let handle: String
    let roleTitle: String
    let bio: String
    let avatarImageName: String
    let postsCount: Int
    let followersCount: Int
    let followingCount: Int
}
