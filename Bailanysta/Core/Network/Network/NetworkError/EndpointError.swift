//
//  EndpointError.swift
//  Alamofire
//
//  Created by Timur Tabynbayev on 7/2/19.
//

import Foundation

public typealias DecodableError = LocalizedError & Decodable

public protocol EndpointError: DecodableError {
    var code: Int? { get }
    var message: String? { get }
}

extension EndpointError {
    public var message: String? {
        nil
    }
}
