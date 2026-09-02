//
//  ResponceModel.swift
//  Kolesa Group
//
//  Created by Arman on 16.06.2022.
//

import Foundation

/// Эта модель ответа может принимать в себе модель или массив из моделей
struct ResponseModel<T: Decodable>: Decodable {
    let success: Bool
    let data: T
}
