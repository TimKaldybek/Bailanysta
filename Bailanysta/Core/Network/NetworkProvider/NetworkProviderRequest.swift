//
//  EnvironmentMergingRequest.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 04.03.2021.
//

import Foundation

/// Объединяет поля Request и Environment
class NetworkProviderRequest<RequestType: Request> {
    private var request: RequestType
    private let environment: RequestType.EnvironmentType
    
    init(request: RequestType) {
        self.request = request
        self.environment = request.environment
    }
    
    var method: HTTPMethod {
        request.method
    }
    
    var url: String {
        var baseUrl = environment.baseUrl
        var path = request.path
        
        baseUrl = baseUrl.last == "/" ? String(baseUrl.dropLast()) : baseUrl
        path = path.first == "/" ? String(path.dropFirst()) : path
        
        return baseUrl + "/" + path
    }
    
    var headers: HTTPHeaders {
        merge(parameters: environment.headers, with: request.headers) ?? HTTPHeaders()
    }
    
    var query: Parameters? {
        merge(parameters: environment.query, with: request.query)
    }
    
    var body: Body? {
        request.body
    }
    
    var bodyRepresentation: BodyRepresentation {
        request.bodyRepresentation ?? environment.bodyRepresentation
    }
    
    private func merge<T>(parameters: [String: T]?, with otherParameters: [String: T]?) -> [String: T]? {
        var result = [String: T]()
        
        if let parameters = parameters {
            result.merge(parameters) { $1 }
        }
        
        if let otherParameters = otherParameters {
            result.merge(otherParameters) { $1 }
        }
        
        return result.isEmpty ? nil : result
    }
}
