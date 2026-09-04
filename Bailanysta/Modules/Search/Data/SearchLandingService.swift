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
        return SearchLandingDTO(trendingTopics: try await trendingTopics, suggestedUsers: try await suggestedUsers)
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
}

// MARK: - Constants

private extension SearchLandingService {
    enum Constants {
        static let trendingTopicsCollection = "trendingTopics"
        static let suggestedUsersCollection = "suggestedUsers"
        static let defaultAvatarImageName = "person.crop.circle.fill"
    }
}
