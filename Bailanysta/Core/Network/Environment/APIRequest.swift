//
//  APIRequest.swift
//  Kolesa Group
//
//  Created by Aimukambetov Sanatzhan on 15.06.2022.
//

protocol APIRequest: Request {}

extension APIRequest {
    var environment: APIEnvironment {
        APIEnvironment()
    }
}
