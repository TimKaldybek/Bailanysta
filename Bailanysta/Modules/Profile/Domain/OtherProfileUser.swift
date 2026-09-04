//
//  OtherProfileUser.swift
//  Bailanysta
//

import Foundation

struct OtherProfileUser: Hashable {
    /// Настоящий Firestore `users/{uid}` идентификатор — нужен, чтобы знать, кого follow/unfollow-ить
    let uid: String
    let name: String
    let handle: String
    let tagline: String
    let avatarImageName: String
    /// Storage download URL, если пользователь загрузил аватар; `nil` — используется `avatarImageName`
    let avatarURL: URL?
    /// `var`, а не `let`: презентер корректирует счётчик на ±1 после подтверждённого follow/unfollow
    var followersCount: Int
    let followingCount: Int
    let postsCount: Int
    /// `var`, а не `let`: презентер обновляет состояние после подтверждённого ответа от Firestore
    var isFollowing: Bool
}
