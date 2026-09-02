//
//  ArticleMapper.swift
//  Bailanysta
//

struct ArticleMapper {
    func map(_ dto: ArticleDTO) -> ArticleItem {
        ArticleItem(
            title:     dto.titleKey.localized,
            subtitle:  dto.subtitleKey.localized,
            urlString: dto.urlString,
            iconName:  dto.iconName
        )
    }
}
