//
//  URLSessionNSError.swift
//  Alamofire
//
//  Created by Timur Tabynbayev on 7/5/19.
//

import Foundation

public struct URLSessionNSError: LocalizedError {
    let error: NSError
    
    public var errorDescription: String? {
        switch error.code {
        case URLError.notConnectedToInternet.rawValue:
            return "Network.ErrorDescription.NoInternetConnection"
        default:
            return error.localizedDescription
        }
    }
    
    public var code: Int? {
        error.code
    }
}
