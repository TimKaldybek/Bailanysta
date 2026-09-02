//
//  FailureHTTPStatusError.swift
//  Alamofire
//
//  Created by Timur Tabynbayev on 7/2/19.
//

import Foundation

public enum HTTPStatus {
    public static let notAuthorized = 401
}

public struct FailureHTTPStatusError: LocalizedError {
    public let status: Int
    public let error: Error
    
    public var errorDescription: String? {
        errorDescription(for: statusForLocalization(status: status)) ?? error.localizedDescription
    }
    
    private func statusForLocalization(status: Int) -> Int {
        switch status {
        case 401:
            return 403
        case 501, 502, 504:
            return 500
        default:
            return status
        }
    }
    
    private func errorDescription(for status: Int) -> String? {
        let localizedKey = "Network.ErrorDescription.HTTP\(status)"
        let description = localizedKey
        
        return description != localizedKey ? description : nil
    }
}
