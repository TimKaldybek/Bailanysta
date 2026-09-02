//
//  Request+DataResponse.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 22.02.2021.
//

import Foundation

public extension Request where ResponseType == Data {
    static func parseSuccess(data: Data) -> NetworkResult<ResponseType> {
        if let endpointError = try? JSONDecoder().decode(EndpointErrorType.self, from: data) {
            return .failure(.endpoint(error: endpointError))
        } else {
            return .success(data)
        }
    }
}
