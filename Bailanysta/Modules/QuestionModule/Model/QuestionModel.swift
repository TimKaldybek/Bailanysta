//
//  QuestionModel.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 13.11.2024.
//

import Foundation

struct QuestionModel: Decodable, Equatable {
    let type: ThemeType
    let title: String
    var isAnswered: Bool
}
