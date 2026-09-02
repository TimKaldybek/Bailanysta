//
//  ThemeMapper.swift
//  Bailanysta
//

import UIKit

struct ThemeMapper {
    func map(_ dto: ThemeDTO) -> ThemeModel? {
        guard let type = ThemeType(rawValue: dto.type) else { return nil }
        return ThemeModel(image: UIImage(named: dto.imageName), type: type)
    }
}
