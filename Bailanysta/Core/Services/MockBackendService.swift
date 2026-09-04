//
//  MockBackendService.swift
//  Bailanysta
//

import Foundation

/// Shared in-memory mock backend standing in for a real server while Feed posts/likes/comments have none yet, so state stays consistent across screens during the app session.
actor MockBackendService {
    static let shared = MockBackendService()

    struct BackendPost {
        let id: String
        let authorName: String
        let authorHandle: String
        let avatarImageName: String
        let timeAgoText: String
        let text: String
        let attachmentImageName: String?
        var likesCount: Int
        var isLiked: Bool
        var commentsCount: Int
    }

    struct BackendComment {
        let id: String
        let postID: String
        let authorName: String
        let authorHandle: String
        let avatarImageName: String
        let timeAgoText: String
        let text: String
    }

    private var posts: [BackendPost]
    private var commentsByPostID: [String: [BackendComment]]

    init() {
        let seedPost = BackendPost(
            id: UUID().uuidString,
            authorName: "Alex Rivera",
            authorHandle: "@arivera",
            avatarImageName: "person.crop.circle.fill",
            timeAgoText: "2h",
            text: "Just wrapped up the new design system overview. The emphasis on spatial typography and tonal elevation is really changing how we approach UI architecture. Loving the 'Indigo Light' direction! 🚀",
            attachmentImageName: "feed_post_design_system_preview",
            likesCount: 245,
            isLiked: false,
            commentsCount: 3
        )

        posts = [seedPost]

        commentsByPostID = [
            seedPost.id: [
                BackendComment(
                    id: UUID().uuidString,
                    postID: seedPost.id,
                    authorName: "Jordan Lee",
                    authorHandle: "@jlee_ux",
                    avatarImageName: "person.crop.circle.fill",
                    timeAgoText: "1h",
                    text: "The tonal elevation shift is such a nice touch — makes the hierarchy feel way more natural."
                ),
                BackendComment(
                    id: UUID().uuidString,
                    postID: seedPost.id,
                    authorName: "Priya Nair",
                    authorHandle: "@priyan",
                    avatarImageName: "person.crop.circle.fill",
                    timeAgoText: "45m",
                    text: "Indigo Light is gorgeous. Are you planning to open-source the token set?"
                ),
                BackendComment(
                    id: UUID().uuidString,
                    postID: seedPost.id,
                    authorName: "Sam Okafor",
                    authorHandle: "@samo_designs",
                    avatarImageName: "person.crop.circle.fill",
                    timeAgoText: "20m",
                    text: "Spatial typography is underrated. Great write-up, saving this for reference."
                )
            ]
        ]
    }

    // MARK: - Public

    func fetchPosts() async -> [BackendPost] {
        try? await Task.sleep(nanoseconds: Constants.fetchPostsDelayNanoseconds)
        return posts
    }

    func toggleLike(postID: String) async -> BackendPost? {
        try? await Task.sleep(nanoseconds: Constants.toggleLikeDelayNanoseconds)

        guard let index = posts.firstIndex(where: { $0.id == postID }) else { return nil }

        posts[index].isLiked.toggle()
        posts[index].likesCount += posts[index].isLiked ? 1 : -1

        return posts[index]
    }

    func fetchComments(postID: String) async -> [BackendComment] {
        try? await Task.sleep(nanoseconds: Constants.fetchCommentsDelayNanoseconds)
        return commentsByPostID[postID] ?? []
    }

    func addComment(postID: String, text: String) async -> BackendComment? {
        try? await Task.sleep(nanoseconds: Constants.addCommentDelayNanoseconds)

        guard posts.contains(where: { $0.id == postID }) else { return nil }

        let comment = BackendComment(
            id: UUID().uuidString,
            postID: postID,
            authorName: Constants.currentUser.name,
            authorHandle: Constants.currentUser.handle,
            avatarImageName: Constants.currentUser.avatarImageName,
            timeAgoText: "Just now",
            text: text
        )

        commentsByPostID[postID, default: []].append(comment)

        if let index = posts.firstIndex(where: { $0.id == postID }) {
            posts[index].commentsCount += 1
        }

        return comment
    }
}

// MARK: - Constants

private extension MockBackendService {
    enum Constants {
        static let fetchPostsDelayNanoseconds: UInt64 = 500_000_000
        static let toggleLikeDelayNanoseconds: UInt64 = 250_000_000
        static let fetchCommentsDelayNanoseconds: UInt64 = 400_000_000
        static let addCommentDelayNanoseconds: UInt64 = 500_000_000

        /// Mock identity for the current user — mirrors `Modules/Profile/Data/ProfileService.swift`
        static let currentUser = (
            name: "Alex Chen",
            handle: "@alexc_designs",
            avatarImageName: "person.crop.circle.fill"
        )
    }
}
