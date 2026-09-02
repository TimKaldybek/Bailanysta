//
//  NetworkProviderError.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 03.03.2021.
//

import Foundation

/// Добавляем сюда кейсы только в том случае, если необходимо такой тип ошибки кастомно обрабатывать на клиентской
/// стороне. Если же нужно только менять localizedDescription, нужно пользоваться типом other
public enum NetworkProviderError: LocalizedError {
    case failureHTTPStatus(error: FailureHTTPStatusError)
    case cancelled(error: Error)
    case urlSessionError(error: URLSessionNSError)
    case other(error: Error)
    
    public var errorDescription: String? {
        switch self {
        case .cancelled(let error), .other(error: let error):
            return error.localizedDescription
        case .failureHTTPStatus(let error):
            return error.localizedDescription
        case .urlSessionError(let error):
            return error.localizedDescription
        }
    }
    
    public var isCancelled: Bool {
        if case .cancelled = self { return true }
        
        return false
    }
    
    public var isUnauthorized: Bool {
        if case .failureHTTPStatus(let statusError) = self,
           statusError.status == HTTPStatus.notAuthorized {
            return true
        }
        
        return false
    }
    
    public var urlSessionError: URLSessionNSError? {
        if case let .urlSessionError(error) = self {
            return error
        }
        
        return nil
    }
    
    public var failureHTTPStatusError: FailureHTTPStatusError? {
        if case let .failureHTTPStatus(error) = self {
            return error
        }
        
        return nil
    }
}
