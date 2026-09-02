//
//  Request+DictionaryResponse.swift
//  Alamofire
//
//  Created by Timur Tabynbayev on 23.07.2021.
//

import Foundation

public extension Request where ResponseType == [String: Any] {
    static func parseSuccess(data: Data) -> NetworkResult<ResponseType> {
        if let endpointError = try? JSONDecoder().decode(EndpointErrorType.self, from: data) {
            return .failure(.endpoint(error: endpointError))
        } else if let object = try? JSONSerialization.jsonObject(with: data),
                  let dictionary = object as? [String: Any] {
            return .success(dictionary)
        } else {
            return .failure(.dataParsing(error: .incorrectFormat))
        }
    }
}
