//
//  AlamofireNetworkClient.swift
//  Network
//
//  Created by Amirzhan on 25.05.2018.
//  Copyright © 2018 TOO Kolesa. All rights reserved.
//

import Alamofire
import Foundation

/// Реализация клиента для отправки HTTP запроса с помощью Alamofire
class AlamofireNetworkClient: NetworkClient {
    private let errorFactory = AlamofireNetworkErrorFactory()
    private let responseQueue = DispatchQueue(label: "kz.kolesa.network.response",
                                              qos: .userInitiated,
                                              attributes: .concurrent)
    
    func execute(request: NetworkRequest,
                 completion: @escaping (URLResponse?, Data?, DeprecatedNetworkError?) -> Void) -> Cancellable? {
        let method = Alamofire.HTTPMethod(rawValue: request.method.rawValue)
        let dataRequest = AF
            .request(request.url,
                     method: method,
                     parameters: request.parameters,
                     encoding: encoding(for: request.bodyRepresentation),
                     headers: Alamofire.HTTPHeaders(request.headers))
            .validate(statusCode: 200..<300)
            .responseJSON(queue: responseQueue) { response in
                let error = response.error != nil ? self.errorFactory.error(from: response.error!) : nil
                completion(response.response, response.data, error)
        }
        
        return AlamofireDataRequest(dataRequest: dataRequest)
    }

    private func encoding(for bodyRepresentation: BodyRepresentation) -> ParameterEncoding {
        switch bodyRepresentation {
        case .formURL:
            return URLEncoding.default
        case .json:
            return JSONEncoding.default
        }
    }
}
