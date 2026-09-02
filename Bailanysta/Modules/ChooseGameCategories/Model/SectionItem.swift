//
//  SectionItem.swift
//  Bailanysta
//

enum SectionItem: Hashable {
    case quickGame
    case theme(ThemeType)
    case tip(RelationshipTip)
    case article(ArticleItem)
}
