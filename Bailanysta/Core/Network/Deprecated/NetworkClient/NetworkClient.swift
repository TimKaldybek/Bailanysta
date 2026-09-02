//
//
//  NetworkClient.swift
//  Network
//
//  Created by Amirzhan on 25.05.2018.
//  Copyright © 2018 TOO Kolesa. All rights reserved.
//

import Foundation

/// Клиент для отправки HTTP запроса на сервер
public protocol NetworkClient {
    /// Выполнить запрос используя данные c request и environment
    ///
    /// - Parameters:
    ///   - request: HTTP запрос
    ///   - completion: Блок ответа от сервера
    /// - Returns: Запрос который может быть отменен пользователем
    func execute(request: NetworkRequest,
                 completion: @escaping(URLResponse?, Data?, DeprecatedNetworkError?) -> Void) -> Cancellable?
}
