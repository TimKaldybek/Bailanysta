//
//  EndpointClient.swift
//  Network
//
//  Created by Amirzhan on 25.05.2018.
//  Copyright © 2018 TOO Kolesa. All rights reserved.
//

/// Клиент для отправки HTTP запросов одной среды на сервер
public protocol EndpointClient {
    /// Выполнить запрос, используя данные c request
    ///
    /// - Parameters:
    ///   - request: HTTP запрос
    ///   - completion: Блок результата запроса
    /// - Returns: Запрос который может быть отменен пользователем
    @discardableResult
    func execute<T: Decodable>(request: EndpointRequest,
                               completion: @escaping (Result<T>) -> Void) -> Cancellable?
}
