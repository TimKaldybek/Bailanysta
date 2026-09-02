//
//  Request+DecodableResponse.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 22.02.2021.
//

import Foundation

public extension Request where ResponseType: Decodable {
    static func parseSuccess(data: Data) -> NetworkResult<ResponseType> {
        // Важно сначала парсить ResponseType и только потом ErrorType,
        // так как в некоторых случаях успешный ответ может спарситься как ErrorType
        // (например, запрос isValidVersion).
        if let response = try? JSONDecoder().decode(ResponseType.self, from: data) {
            return .success(response)
        } else if let endpointError = try? JSONDecoder().decode(EndpointErrorType.self, from: data) {
            return .failure(.endpoint(error: endpointError))
        } else {
            return .failure(.incorrectFormat)
        }
    }
}
