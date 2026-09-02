//
//  DataParsingError.swift
//  Alamofire
//
//  Created by Timur Tabynbayev on 7/5/19.
//

import Foundation

public enum DataParsingError: LocalizedError {
    case noData
    case incorrectFormat
    
    public var errorDescription: String? {
        switch self {
        case .noData:
            return "Нет данных от сервера"
        case .incorrectFormat:
            return "Неверный формат данных"
        }
    }
}
