//
//  AlamofireNetworkErrorFactory.swift
//  Network
//
//  Created by Timur Tabynbayev on 7/2/19.
//

import Alamofire
import Foundation

struct AlamofireNetworkErrorFactory {
    func error(from error: AFError) -> DeprecatedNetworkError {
        if case let .responseValidationFailed(reason) = error,
           case let .unacceptableStatusCode(code) = reason {
            let failureError = FailureHTTPStatusError(status: code,
                                                      error: error)
            return .failureHTTPStatus(error: failureError)
        } else if case let .sessionTaskFailed(error: error) = error {
            return .other(error: URLSessionNSError(error: error as NSError))
        } else {
            return .other(error: error)
        }
    }
}
