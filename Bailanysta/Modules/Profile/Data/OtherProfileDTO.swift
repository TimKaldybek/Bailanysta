//
//  OtherProfileDTO.swift
//  Bailanysta
//

struct OtherProfileUserDTO {
    let id: String
    let name: String
    let handle: String
    let tagline: String
    let avatarImageName: String
    /// Storage download URL, если пользователь загрузил аватар; `nil` — используется `avatarImageName`
    let avatarURL: String?
    let followersCount: Int
    let followingCount: Int
    let postsCount: Int
    let isFollowing: Bool
}

struct OtherProfileDTO {
    let user: OtherProfileUserDTO
    let posts: [ProfilePostDTO]
    let likes: [ProfilePostDTO]
    let replies: [ProfilePostDTO]
}
