//
//  OtherProfileViewData.swift
//  Bailanysta
//

import Foundation

struct OtherProfileViewData {
    let header: OtherProfileHeaderViewData
    let selectedTab: ProfileTab
    let items: [ProfilePostViewData]
    /// One-off failure message (e.g. follow/unfollow failed) — `nil` when there's nothing to show
    let errorMessage: String?
}

struct OtherProfileHeaderViewData {
    let avatarImageName: String
    let avatarURL: URL?
    let name: String
    let tagline: String
    let followersCountText: String
    let followingCountText: String
    let postsCountText: String
    let followButtonTitle: String
    let isFollowing: Bool
}
