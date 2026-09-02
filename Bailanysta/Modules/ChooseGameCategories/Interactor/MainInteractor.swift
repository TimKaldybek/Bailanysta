//
//  MainInteractor.swift
//  Bailanysta
//

import Foundation

final class MainInteractor {
    private let themeMapper   = ThemeMapper()
    private let articleMapper = ArticleMapper()

    func fetchCategories() async -> CategoriesData {
        async let categoriesDTO = loadCategoriesDTO()
        async let tips          = loadTips()

        let (dto, loadedTips) = await (categoriesDTO, tips)

        return CategoriesData(
            deepThemes: dto.deep.compactMap(themeMapper.map),
            funThemes:  dto.fun.compactMap(themeMapper.map),
            tips:       loadedTips,
            articles:   dto.articles.map(articleMapper.map)
        )
    }

    private func loadTips() async -> [RelationshipTip] {
        await Task {
            guard
                let url  = Bundle.main.url(forResource: "tips", withExtension: "json"),
                let data = try? Data(contentsOf: url),
                let dto  = try? JSONDecoder().decode(RelationshipTipsDTO.self, from: data)
            else {
                assertionFailure("Failed to load tips.json")
                return []
            }

            return dto.tips.map { RelationshipTip(id: $0.id, text: $0.textKey.localized) }
        }.value
    }

    private func loadCategoriesDTO() async -> CategoriesDTO {
        await Task {
            guard
                let url  = Bundle.main.url(forResource: "categories", withExtension: "json"),
                let data = try? Data(contentsOf: url),
                let dto  = try? JSONDecoder().decode(CategoriesDTO.self, from: data)
            else {
                assertionFailure("Failed to load categories.json")
                return CategoriesDTO(deep: [], fun: [], articles: [])
            }

            return dto
        }.value
    }
}
