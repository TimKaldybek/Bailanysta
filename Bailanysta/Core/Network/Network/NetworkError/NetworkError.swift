//
//  NetworkError.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 18.03.2021.
//

import Foundation

public enum NetworkError: LocalizedError {
    case endpoint(error: EndpointError)
    case networkProvider(error: NetworkProviderError)
    case dataParsing(error: DataParsingError)
    
    public var errorDescription: String? {
        switch self {
        case .endpoint(let error):
            return error.localizedDescription
        case .networkProvider(let error):
            return error.localizedDescription
        case .dataParsing(let error):
            return error.localizedDescription
        }
    }
    
    public static var incorrectFormat: Self {
        .dataParsing(error: .incorrectFormat)
    }
    
    public static var noData: Self {
        .dataParsing(error: .noData)
    }
    
    public var isCancelled: Bool {
        networkProviderError?.isCancelled ?? false
    }
}

extension NetworkError {
    public var endpointError: EndpointError? {
        if case let .endpoint(error) = self {
            return error
        }
        
        return nil
    }
    
    public var networkProviderError: NetworkProviderError? {
        if case let .networkProvider(error) = self {
            return error
        }
        
        return nil
    }
    
    public var urlSessionError: URLSessionNSError? {
        networkProviderError?.urlSessionError
    }
    
    public var failureHTTPStatusError: FailureHTTPStatusError? {
        networkProviderError?.failureHTTPStatusError
    }
}
