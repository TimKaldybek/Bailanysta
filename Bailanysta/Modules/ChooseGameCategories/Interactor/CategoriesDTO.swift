//
//  CategoriesDTO.swift
//  Bailanysta
//

struct CategoriesDTO: Decodable {
    let deep: [ThemeDTO]
    let fun: [ThemeDTO]
    let articles: [ArticleDTO]
}

struct ThemeDTO: Decodable {
    let type: String
    let imageName: String
}

struct ArticleDTO: Decodable {
    let titleKey: String
    let subtitleKey: String
    let urlString: String
    let iconName: String
}

struct RelationshipTipsDTO: Decodable {
    let tips: [RelationshipTipDTO]
}

struct RelationshipTipDTO: Decodable {
    let id: Int
    let textKey: String
}
