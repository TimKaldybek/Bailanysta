//
//  ArticleItem.swift
//  Bailanysta
//

import Foundation

struct ArticleItem: Hashable {
    let title: String
    let subtitle: String
    let url: URL
    let iconName: String

    init(title: String, subtitle: String, urlString: String, iconName: String) {
        guard let url = URL(string: urlString) else {
            preconditionFailure("Invalid article URL: \(urlString)")
        }
        self.title    = title
        self.subtitle = subtitle
        self.url      = url
        self.iconName = iconName
    }
}
