//
//  SearchLandingService.swift
//  Bailanysta
//

import FirebaseFirestore

/// Reads the Search landing screen's editorial content from Firestore. Mirrors
/// `FeedPostsService`'s read/mapping style.
final class SearchLandingService {
    private let firestore: Firestore

    init(firestore: Firestore = Firestore.firestore()) {
        self.firestore = firestore
    }

    func loadData() async throws -> SearchLandingDTO {
        async let trendingTopics = fetchTrendingTopics()
        async let suggestedUsers = fetchSuggestedUsers()
        async let popularHashtags = fetchPopularHashtags()
        return SearchLandingDTO(
            trendingTopics: try await trendingTopics,
            suggestedUsers: try await suggestedUsers,
            popularHashtags: try await popularHashtags
        )
    }
}

// MARK: - Private

private extension SearchLandingService {
    func fetchTrendingTopics() async throws -> [TrendingTopicDTO] {
        let snapshot = try await firestore.collection(Constants.trendingTopicsCollection)
            .order(by: "rank")
            .getDocuments()
        return snapshot.documents.map(Self.mapTrendingTopic)
    }

    func fetchSuggestedUsers() async throws -> [SuggestedUserDTO] {
        let snapshot = try await firestore.collection(Constants.suggestedUsersCollection).getDocuments()
        return snapshot.documents.map(Self.mapSuggestedUser)
    }

    func fetchPopularHashtags() async throws -> [HashtagDTO] {
        let snapshot = try await firestore.collection(Constants.hashtagsCollection)
            .order(by: "count", descending: true)
            .limit(to: Constants.popularHashtagsLimit)
            .getDocuments()
        return snapshot.documents.map(Self.mapHashtag)
    }

    static func mapTrendingTopic(_ document: QueryDocumentSnapshot) -> TrendingTopicDTO {
        let data = document.data()
        return TrendingTopicDTO(
            id: document.documentID,
            rank: data["rank"] as? Int ?? 0,
            category: data["category"] as? String ?? "",
            title: data["title"] as? String ?? "",
            subtitle: data["subtitle"] as? String ?? "",
            imageURL: data["imageURL"] as? String
        )
    }

    static func mapSuggestedUser(_ document: QueryDocumentSnapshot) -> SuggestedUserDTO {
        let data = document.data()
        return SuggestedUserDTO(
            id: document.documentID,
            name: data["name"] as? String ?? "",
            handle: data["handle"] as? String ?? "",
            avatarImageName: Constants.defaultAvatarImageName,
            avatarURL: data["avatarURL"] as? String
        )
    }

    static func mapHashtag(_ document: QueryDocumentSnapshot) -> HashtagDTO {
        let data = document.data()
        return HashtagDTO(
            id: document.documentID,
            tag: data["tag"] as? String ?? "",
            count: data["count"] as? Int ?? 0
        )
    }
}

// MARK: - Constants

private extension SearchLandingService {
    enum Constants {
        static let trendingTopicsCollection = "trendingTopics"
        static let suggestedUsersCollection = "suggestedUsers"
        static let hashtagsCollection = "hashtags"
        static let defaultAvatarImageName = "person.crop.circle.fill"
        static let popularHashtagsLimit = 15
    }
}
