//
//  Cancellable.swift
//  Network
//
//  Created by Islam Temirbek on 7/19/18.
//

/// Протокол для отмены запроса
public protocol Cancellable {
    /// Метод для отмены запроса
    func cancel()
    
    /// Выполнился ли уже запрос. Если запрос уже выполнился, то его можно удалять из памяти,
    /// т.к отменять его уже будет не нужно
    func isFinished() -> Bool
}
