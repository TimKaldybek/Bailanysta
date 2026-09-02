//
//  APIEnvironment.swift
//  Kolesa Group
//
//  Created by Aimukambetov Sanatzhan on 15.06.2022.
//

struct APIEnvironment: Environment {
    typealias EndpointErrorType = APIError
    
    var baseUrl: String {
        "http://kolesa-info-backend.common-production.k8s.alaps.kz.prod.bash.kz:8080/api/"
    }
    
    var bodyRepresentation: BodyRepresentation? {
        .formURL
    }
}
