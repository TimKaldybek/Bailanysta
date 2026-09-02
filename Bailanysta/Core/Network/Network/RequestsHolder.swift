//
//  RequestsHolder.swift
//  Network
//
//  Created by Amirzhan on 06.08.2018.
//  Copyright © 2018 Kolesa LLC. All rights reserved.
//

/// Протокол для классов, содержащих отменяемые интернет запросы
public protocol RequestsHolderProtocol: AnyObject {
    /// Добавить запрос
    func add(request: Cancellable)
    
    /// Отменить все добавленные запросы
    func cancelRequests()
}

/// Класс, содержащий отменяемые интернет запросы
public class RequestsHolder: RequestsHolderProtocol {
    private var requests = [Cancellable]()
    
    public init() {}
    
    public func add(request: Cancellable) {
        requests.append(request)
        clearFromFinishedRequests()
    }
    
    public func cancelRequests() {
        requests.forEach { request in
            request.cancel()
        }
    }
    
    private func clearFromFinishedRequests() {
        requests = requests.filter { request -> Bool in
            !request.isFinished()
        }
    }
    
    deinit {
        cancelRequests()
    }
}
