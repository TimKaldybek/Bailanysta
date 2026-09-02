//
//  NetworkProviderError+Alamofire.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 04.03.2021.
//

import Foundation
import Alamofire

extension NetworkProviderError {
    init(afError: AFError) {
        if afError.isCancelled {
            self = .cancelled(error: afError)
        } else if let code = afError.responseCode {
            self = .failureHTTPStatus(error: FailureHTTPStatusError(status: code,
                                                                    error: afError))
        } else if case let .sessionTaskFailed(error as NSError) = afError {
            self = .urlSessionError(error: URLSessionNSError(error: error))
        } else {
            self = .other(error: afError)
        }
    }
}

private extension AFError {
    var isCancelled: Bool {
        if case let .sessionTaskFailed(error as NSError) = self, error.code == URLError.cancelled.rawValue {
            return true
        }
        
        return isExplicitlyCancelledError
    }
}
