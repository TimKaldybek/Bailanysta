//
//  SearchLandingDataProvider.swift
//  Bailanysta
//

struct SearchLandingDataProvider {
    private let service: SearchLandingService

    init(service: SearchLandingService) {
        self.service = service
    }

    func loadData() async -> SearchModel {
        let dto = await service.loadData()
        return SearchModel(
            trendingTopics: dto.trendingTopics.map(Self.map),
            suggestedUsers: dto.suggestedUsers.map(Self.map)
        )
    }

    private static func map(_ dto: TrendingTopicDTO) -> TrendingTopic {
        TrendingTopic(id: dto.id, rank: dto.rank, category: dto.category, title: dto.title, subtitle: dto.subtitle)
    }

    private static func map(_ dto: SuggestedUserDTO) -> SuggestedUser {
        SuggestedUser(id: dto.id, name: dto.name, handle: dto.handle, avatarImageName: dto.avatarImageName, isFollowing: false)
    }
}
