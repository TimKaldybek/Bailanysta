//
//  APIError.swift
//  Kolesa Group
//
//  Created by Aimukambetov Sanatzhan on 15.06.2022.
//

struct APIError: EndpointError {
    private let errorCode: Int
    private let title: String
    
    var code: Int? {
        errorCode
    }
}
