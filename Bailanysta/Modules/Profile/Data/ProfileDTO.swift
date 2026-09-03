//
//  ProfileDTO.swift
//  Bailanysta
//

struct ProfileUserDTO {
    let id: String
    let name: String
    let handle: String
    let roleTitle: String
    let bio: String
    let avatarImageName: String
    let postsCount: Int
    let followersCount: Int
    let followingCount: Int
}

struct ProfilePostDTO {
    let id: String
    let authorName: String
    let authorHandle: String
    let avatarImageName: String
    let timeAgoText: String
    let text: String
    let attachmentImageName: String?
    let commentsCount: Int
    let repostsCount: Int
    let likesCount: Int
    let viewsCount: Int
}

struct ProfileDTO {
    let user: ProfileUserDTO
    let posts: [ProfilePostDTO]
    let replies: [ProfilePostDTO]
    let likes: [ProfilePostDTO]
}
