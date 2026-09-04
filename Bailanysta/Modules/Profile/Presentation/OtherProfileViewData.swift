//
//  OtherProfileViewData.swift
//  Bailanysta
//

struct OtherProfileViewData {
    let header: OtherProfileHeaderViewData
    let selectedTab: ProfileTab
    let items: [ProfilePostViewData]
}

struct OtherProfileHeaderViewData {
    let avatarImageName: String
    let name: String
    let tagline: String
    let followersCountText: String
    let followingCountText: String
    let postsCountText: String
    let followButtonTitle: String
    let isFollowing: Bool
}
