//
//  BaseEndpointClient.swift
//  Alamofire
//
//  Created by Amirzhan on 10.07.2018.
//

import Foundation

/// Базовый класс реализации EndpointClient-a. Подклассам необходимо установить среду запроса.
open class BaseEndpointClient<ErrorType: EndpointError>: EndpointClient {
    /// Объект создания общих параметров для запросов клиента
    public var environment: EndpointEnvironment!
    
    /// Клиент для отправки HTTP запроса на сервер
    public var networkClient: NetworkClient
    
    public init() {
        self.networkClient = AlamofireNetworkClient()
    }
    
    @discardableResult
    public final func execute<T: Decodable>(request: EndpointRequest,
                                            completion: @escaping (Result<T>) -> Void) -> Cancellable? {
        let networkRequest = NetworkRequest(request: request, environment: environment)
        
        let cancellable = networkClient.execute(request: networkRequest) { _, data, error in
            let result: Result<T> = self.resultFrom(data: data, error: error)
            DispatchQueue.main.async {
                completion(result)
            }
        }

        return cancellable
    }
    
    /// При использовании убедитесь, что успешный ответ не может быть спарсен как ответ об ошибке
    @discardableResult
    public final func execute(request: EndpointRequest, completion: ((Result<Data>) -> Void)? = nil) -> Cancellable? {
        let networkRequest = NetworkRequest(request: request, environment: environment)

        let cancellable = networkClient.execute(request: networkRequest) { _, data, error in
            let result: Result<Data> = self.resultFrom(data: data, error: error)
            DispatchQueue.main.async {
                completion?(result)
            }
        }
        
        return cancellable
    }
    
    // НЕ МЕНЯТЬ порядок декодинга T и ErrorType
    private func resultFrom<T: Decodable>(data: Data?, error: DeprecatedNetworkError?) -> Result<T> {
        if let error = error {
            if let data = data, let endpointError = try? JSONDecoder().decode(ErrorType.self, from: data) {
                return .failure(.endpoint(error: endpointError))
            } else {
                return .failure(error)
            }
        }
        
        guard let data = data else {
            return .failure(.noData)
        }
        
        if let response = try? JSONDecoder().decode(T.self, from: data) {
            return .success(response)
        }
        
        // Важно сначала парсить T и только потом ErrorType,
        // так как в некоторых случаях успешный ответ может спарситься как ErrorType
        // (например, запрос isValidVersion).
        if let endpointError = try? JSONDecoder().decode(ErrorType.self, from: data) {
            return .failure(.endpoint(error: endpointError))
        }
        
        return .failure(.incorrectFormat)
    }
    
    private func resultFrom(data: Data?, error: DeprecatedNetworkError?) -> Result<Data> {
        if let error = error {
            return .failure(error)
        }
        
        guard let data = data else {
            return .failure(.noData)
        }
        
        if let endpointError = try? JSONDecoder().decode(ErrorType.self, from: data) {
            return .failure(.endpoint(error: endpointError))
        }
    
        return .success(data)
    }
}
