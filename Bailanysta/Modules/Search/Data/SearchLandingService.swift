//
//  SearchLandingService.swift
//  Bailanysta
//

final class SearchLandingService {
    func loadData() async -> SearchLandingDTO {
        Constants.mockData
    }
}

// MARK: - Constants

private extension SearchLandingService {
    enum Constants {
        /// Локальный источник данных на время отсутствия бэкенда
        static let mockData = SearchLandingDTO(
            trendingTopics: [
                TrendingTopicDTO(
                    id: "quantum-computing",
                    rank: 1,
                    category: "Technology",
                    title: "Quantum Computing",
                    subtitle: "The race for supremacy in processing power."
                ),
                TrendingTopicDTO(
                    id: "generative-art",
                    rank: 2,
                    category: "Art",
                    title: "Generative Art",
                    subtitle: "How algorithms redefine visual creativity."
                ),
                TrendingTopicDTO(
                    id: "remote-work-future",
                    rank: 3,
                    category: "Business",
                    title: "Remote Work Future",
                    subtitle: "How global teams are adapting to async collaboration."
                )
            ],
            suggestedUsers: [
                SuggestedUserDTO(
                    id: "erost_design",
                    name: "Elena Rostova",
                    handle: "@erost_design",
                    avatarImageName: "person.crop.circle.fill"
                ),
                SuggestedUserDTO(
                    id: "mv_quantum",
                    name: "Marcus Vance",
                    handle: "@mv_quantum",
                    avatarImageName: "person.crop.circle.fill"
                ),
                SuggestedUserDTO(
                    id: "voidsys_art",
                    name: "Void_Sys",
                    handle: "@voidsys_art",
                    avatarImageName: "person.crop.circle.fill"
                )
            ]
        )
    }
}
