//
//  NetworkError+CustomNSError.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 28.10.2021.
//

import Foundation

extension NetworkError: CustomNSError {
    public static var errorDomain: String {
        "network.kolesa.kz"
    }
    
    public var errorCode: Int {
        endpointError?.code ?? networkProviderError?.urlSessionError?.code ?? 0
    }
    
    public var errorUserInfo: [String: Any] {
        var userInfo = [String: Any]()
        userInfo[NSLocalizedDescriptionKey] = errorDescription
        userInfo[NetworkNSErrorUserInfoKeys.isCancelled] = isCancelled
        
        return userInfo
    }
}
