//
//  Request+Failure.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 23.02.2021.
//

import Foundation

public extension Request {
    static func parseFailure(data: Data, error: NetworkProviderError) -> NetworkResult<ResponseType> {
        let endpointError = try? JSONDecoder().decode(EndpointErrorType.self, from: data)
        return .failure(endpointError.map { .endpoint(error: $0) } ?? .networkProvider(error: error))
    }
}
