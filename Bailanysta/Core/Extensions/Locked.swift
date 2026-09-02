//
//  Locked.swift
//  Bailanysta
//
//  Created by Timur Kaldybek on 25.06.2025.
//

import Foundation

@propertyWrapper
final class Locked<Value> {
    public var wrappedValue: Value {
        get { lock.sync { self.value } }
        
        set { lock.sync { self.value = newValue } }
    }
    
    private var value: Value
    
    private let lock = NSRecursiveLock()
    
    public init(wrappedValue: Value) {
        self.value = wrappedValue
    }
}

private extension NSRecursiveLock {
    @discardableResult
    func sync<R>(work: () throws -> R) rethrows -> R {
        self.lock()
        
        defer { self.unlock() }
        
        return try work()
    }
}
