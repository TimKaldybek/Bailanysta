//
//  NetworkProviderRequest+Alamofire.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 22.02.2021.
//

import Foundation
import Alamofire

extension NetworkProviderRequest {
    /// Создаёт  URLRequest. Сетит ему заголовки, http метод, query и параметры в body.
    /// Но НЕ сетит multipart data в body.
    func urlRequest() throws -> URLRequest {
        guard let url = URL(string: url) else {
            throw AFError.invalidURL(url: self.url)
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.allHTTPHeaderFields = headers
        urlRequest.httpMethod = method.rawValue
        
        if let query = query {
            urlRequest = try urlRequest.urlEncoded(parameters: query)
        }
        
        if case let .parameters(parameters) = body {
            urlRequest = try urlRequest.bodyEncoded(parameters: parameters,
                                                    bodyRepresentation: bodyRepresentation)
        }
        
        return urlRequest
    }
}

private extension URLRequest {
    func urlEncoded(parameters: [String: Any]) throws -> URLRequest {
        try URLEncoding(destination: .queryString).encode(self, with: parameters)
    }
    
    func bodyEncoded(parameters: [String: Any], bodyRepresentation: BodyRepresentation) throws -> URLRequest {
        try encoding(for: bodyRepresentation).encode(self, with: parameters)
    }
    
    private func encoding(for bodyRepresentation: BodyRepresentation) -> ParameterEncoding {
        switch bodyRepresentation {
        case .formURL:
            return URLEncoding(destination: .httpBody)
        case .json:
            return JSONEncoding.default
        }
    }
}
