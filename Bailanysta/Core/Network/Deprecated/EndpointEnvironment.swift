//
//  EndpointEnvironment.swift
//  Network
//
//  Created by Amirzhan on 25.05.2018.
//  Copyright © 2018 TOO Kolesa. All rights reserved.
//

import Foundation

/// Объект создания общих параметров для запросов одной среды
public protocol EndpointEnvironment {
    /// url-хост запросов.
    ///
    /// Корректно работает и при наличии, и при отсутствии слэша в конце. Но рекомендуется в конце слэш НЕ ставить.
    var host: String { get }
    
    /// Заголовки всех запросов
    var headers: HTTPHeaders? { get }
    
    /// Формат данных в теле запроса
    var bodyRepresentation: BodyRepresentation? { get }
    
    /// Параметры всех запросов
    var parameters: Parameters? { get }
}

public extension EndpointEnvironment {
    var bodyRepresentation: BodyRepresentation? {
        nil
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var parameters: Parameters? {
        nil
    }
}
