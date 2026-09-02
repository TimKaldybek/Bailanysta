//
//  NetworkContainer.swift
//  Network
//
//  Created by Timur Tabynbayev on 9/30/19.
//

import Foundation

/// DI-контейнер для библиотеки Network. Чтобы не подключать библиотеку DI сюда.
public class NetworkContainer: NSObject {
    @objc public static let shared = NetworkContainer()
    
    @objc public var defaultHeaders: NetworkDefaultHeaders?
}
