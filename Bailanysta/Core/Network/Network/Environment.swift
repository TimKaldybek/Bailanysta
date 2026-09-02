//
//  Environment.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 15.02.2021.
//

import Foundation

/// Задаёт общие данные для всех запросов в один API: хост, дефолтные заголовки, параметры в query и т.д.
public protocol Environment {
    /// Тип ошибки бэка. То, что парсится из ответа сервера.
    associatedtype EndpointErrorType: EndpointError
        
    /// baseURL всех запросов.
    ///
    /// Корректно работает и при наличии, и при отсутствии слэша в конце. Но рекомендуется в конце слэш НЕ ставить.
    var baseUrl: String { get }
    
    /// Заголовки всех запросов
    var headers: HTTPHeaders? { get }
    
    /// Параметры всех запросов
    var query: Parameters? { get }
    
    /// Формат данных в теле запроса
    var bodyRepresentation: BodyRepresentation { get }
}

public extension Environment {
    var headers: HTTPHeaders? {
        nil
    }
    
    var query: Parameters? {
        nil
    }
    
    var bodyRepresentation: BodyRepresentation {
        .formURL
    }
}
