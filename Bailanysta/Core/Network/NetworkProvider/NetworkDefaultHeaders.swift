//
//  NetworkDefaultHeaders.swift
//  Network
//
//  Created by Timur Tabynbayev on 9/27/19.
//

import Foundation

/// Протокол сущности, отдающей хедеры, которые будут добавлены во все запросы, выполняемые через библиотеку Network.
@objc public protocol NetworkDefaultHeaders: AnyObject {
    @objc var headersDictionary: [String: String] { get }
}
