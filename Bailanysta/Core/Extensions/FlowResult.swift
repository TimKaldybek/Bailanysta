//
//  FlowResult.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 22.06.2025.
//

import Foundation

enum FlowResult<T> {
    case success(T)
    case failure(String)
}
