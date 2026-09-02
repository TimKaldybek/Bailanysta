//
//  Collection+Extension.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 03.04.2025.
//

import Foundation

extension Collection {
    var isNotEmpty: Bool {
        !isEmpty
    }
}

extension Array {
    func firstOfType<T>() -> T? {
        first { $0 is T } as? T
    }
}
