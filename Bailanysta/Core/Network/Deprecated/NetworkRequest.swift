//
//  NetworkRequest.swift
//  Alamofire
//
//  Created by Amirzhan on 12.06.2018.
//

import Foundation

/// Объект создания HTTP запроса.
/// Используется для объединения данных конкретного запроса и его среды
public class NetworkRequest {
    private let request: EndpointRequest
    private let environment: EndpointEnvironment
    
    /// Инициализация
    ///
    /// - Parameters:
    ///   - request: Объект создания HTTP запроса одной среды
    ///   - environment: Объект создания общих параметров для запросов одной среды
    public init(request: EndpointRequest, environment: EndpointEnvironment) {
        self.request = request
        self.environment = environment
    }
    
    /// url запроса. Формируется из свойства host из environment и свойства path из request.
    ///
    /// Корректно работает при любых вариантах расположения слэша (в конце host, в начале path, и любые их комбинации)
    public lazy var url: String = {
        let host = environment.host.last == "/" ? String(environment.host.dropLast()) : environment.host
        let path = request.path.first == "/" ? String(request.path.dropFirst()) : request.path
        return host + "/" + path
    }()
    
    /// Заголовки запроса
    public lazy var headers: HTTPHeaders = {
        var headers = merge(parameters: environment.headers, with: request.headers)
        
        if let defaultHeaders = NetworkContainer.shared.defaultHeaders?.headersDictionary {
            headers.merge(defaultHeaders) { $1 }
        }
        
        return headers
    }()
    
    /// Параметры запроса
    public lazy var parameters: Parameters = {
        merge(parameters: environment.parameters, with: request.parameters)
    }()
    
    /// Формат данных в теле запроса
    public lazy var bodyRepresentation: BodyRepresentation = {
        if request.method == .get {
            return .formURL
        }
        
        if let requestBodyRepresentation = request.bodyRepresentation {
            return requestBodyRepresentation
        }
        
        if let environmentBodyRepresentation = environment.bodyRepresentation {
            return environmentBodyRepresentation
        }
        
        return .json
    }()
    
    /// HTTP метод запроса
    public lazy var method: HTTPMethod = {
        request.method
    }()
    
    private func merge<T>(parameters: [String: T]?, with otherParameters: [String: T]?) -> [String: T] {
        var result = [String: T]()
        
        if let parameters = parameters {
            result.merge(parameters) { $1 }
        }
        
        if let otherParameters = otherParameters {
            result.merge(otherParameters) { $1 }
        }
        
        return result
    }
}
