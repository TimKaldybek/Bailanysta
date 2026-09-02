//
//  Network.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 15.02.2021.
//

import Foundation

/// Сущность для выполнения запросов, следующих протоколу Request.
public final class Network {
    /// Провайдер для отправки HTTP запроса на сервер
    private let networkProvider = AlamofireNetworkProvider(additionalHeaders: NetworkContainer.shared.defaultHeaders)
    
    public init() {}
    
    /// Выполняет запрос.
    ///
    /// - Parameters:
    ///   - request: Дженерик объект запроса
    ///   - completion: Принимает result. Выполняется в главном потоке
    /// - Returns: Отменяемый объект
    @discardableResult
    public func execute<T: Request>(request: T,
                                    completion: @escaping (NetworkResult<T.ResponseType>) -> Void) -> Cancellable? {
        execute(request: request, uploadProgress: nil, completion: completion)
    }
    
    /// Выполняет запрос.
    ///
    /// - Parameters:
    ///   - request: Дженерик объект запроса
    ///   - completion: Принимает result и data. Выполняется в главном потоке
    /// - Returns: Отменяемый объект
    @discardableResult
    public func execute<T: Request>(request: T,
                                    completion: ((NetworkResult<T.ResponseType>, Data?) -> Void)? = nil)
            -> Cancellable? {
        execute(request: request, uploadProgress: nil, completion: completion)
    }
    
    /// Выполняет запрос.
    ///
    /// - Parameters:
    ///   - request: Дженерик объект запроса
    ///   - uploadProgress: Замыкание для отслеживания прогресса. Работает только для multipart запросов,
    ///   выполняется в главном потоке.
    ///   - completion: Принимает result. Выполняется в главном потоке
    /// - Returns: Отменяемый объект
    @discardableResult
    public func execute<T: Request>(request: T,
                                    uploadProgress: ProgressHandler?,
                                    completion: @escaping (NetworkResult<T.ResponseType>) -> Void) -> Cancellable? {
        execute(request: request, uploadProgress: uploadProgress) { result, _ in
            completion(result)
        }
    }
    
    /// Выполняет запрос.
    ///
    /// - Parameters:
    ///   - request: Дженерик объект запроса
    ///   - uploadProgress: Замыкание для отслеживания прогресса. Работает только для multipart запросов,
    ///   выполняется в главном потоке.
    ///   - completion: Принимает result и data. Выполняется в главном потоке
    /// - Returns: Отменяемый объект
    @discardableResult
    public func execute<T: Request>(request: T,
                                    uploadProgress: ProgressHandler?,
                                    completion: ((NetworkResult<T.ResponseType>, Data?) -> Void)?) -> Cancellable? {
        let networkProviderRequest = NetworkProviderRequest(request: request)
        
        return networkProvider.execute(request: networkProviderRequest,
                                       uploadProgress: uploadProgress) { _, data, error in            
            guard let completion = completion else { return }

            let result = self.result(for: request, data: data, error: error)
            
            DispatchQueue.main.async {
                completion(result, data)
            }
        }
    }
    
    private func result<T: Request>(for request: T,
                                    data: Data?,
                                    error: NetworkProviderError?) -> NetworkResult<T.ResponseType> {
        switch (data, error) {
        case (nil, nil):
            return .failure(.noData)
        case let (nil, .some(error)):
            return .failure(.networkProvider(error: error))
        case let (.some(data), nil):
            return T.parseSuccess(data: data)
        case let (.some(data), .some(error)):
            return T.parseFailure(data: data, error: error)
        }
    }
}
