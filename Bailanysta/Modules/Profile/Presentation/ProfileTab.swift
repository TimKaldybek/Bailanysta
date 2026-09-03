//
//  ProfileTab.swift
//  Bailanysta
//

enum ProfileTab: CaseIterable, Hashable {
    case posts
    case replies
    case likes

    var title: String {
        switch self {
        case .posts: return "Profile.Tab.Posts".localized
        case .replies: return "Profile.Tab.Replies".localized
        case .likes: return "Profile.Tab.Likes".localized
        }
    }
}
