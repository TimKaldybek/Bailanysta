//
//  DefaultEndpointError.swift
//  Alamofire
//
//  Created by Amirzhan on 02.07.2018.
//

public struct DefaultEndpointError: EndpointError {
    let error: String
    let errorCode: Int
    
    public var code: Int? {
        errorCode
    }
    
    public var errorDescription: String? {
        error
    }
}
