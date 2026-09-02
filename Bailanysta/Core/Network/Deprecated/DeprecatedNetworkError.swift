//
//  DeprecatedNetworkError.swift
//  Network
//
//  Created by Timur Tabynbayev on 7/2/19.
//

import Foundation

/// Используется в старом EndpointClient-based подходе. Удалим, когда перейдём полностью на новый подход.
public enum DeprecatedNetworkError: LocalizedError {
    case endpoint(error: EndpointError)
    case failureHTTPStatus(error: FailureHTTPStatusError)
    case other(error: Error)
    
    public var errorDescription: String? {
        switch self {
        case .endpoint(let error):
            return error.localizedDescription
        case .failureHTTPStatus(let error):
            return error.localizedDescription
        case .other(let error):
            return error.localizedDescription
        }
    }
    
    public static var incorrectFormat: Self {
        .other(error: DataParsingError.incorrectFormat)
    }
    
    public static var noData: Self {
        .other(error: DataParsingError.noData)
    }
}
