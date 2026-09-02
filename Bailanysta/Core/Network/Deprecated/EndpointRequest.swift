//
//  EndpointRequest.swift
//  Network
//
//  Created by Amirzhan on 25.05.2018.
//  Copyright © 2018 TOO Kolesa. All rights reserved.
//

import Foundation

public typealias Parameters = [String: Any]
public typealias HTTPHeaders = [String: String]

/// Объект создания HTTP запроса одной среды
public protocol EndpointRequest {
    /// url-путь запроса
    ///
    /// Корректно работает и при наличии, и при отсутствии слэша в начале. Но рекомендуется ставить в начале слэш.
    var path: String { get }
    
    /// HTTP метод запроса
    var method: HTTPMethod { get }
    
    /// Заголовки запроса
    var headers: HTTPHeaders? { get }
    
    /// параметры запроса
    var parameters: Parameters? { get }
    
    /// Формат данных в теле запроса
    var bodyRepresentation: BodyRepresentation? { get }
}

public extension EndpointRequest {
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var parameters: Parameters? {
        nil
    }
    
    var bodyRepresentation: BodyRepresentation? {
        nil
    }
}
