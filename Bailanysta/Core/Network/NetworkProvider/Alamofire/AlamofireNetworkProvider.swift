//
//  AlamofireNetworkProvider.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 16.02.2021.
//

import Foundation
import Alamofire

public typealias ProgressHandler = Alamofire.Request.ProgressHandler

/// Реализация провайдера для отправки HTTP запроса с помощью Alamofire
class AlamofireNetworkProvider {
    private let errorFactory = AlamofireNetworkErrorFactory()
    private let responseQueue = DispatchQueue(label: "kz.kolesa.network.response",
                                              qos: .userInitiated,
                                              attributes: .concurrent)
    
    private let additionalHeaders: NetworkDefaultHeaders?
    
    private let session = Session(interceptor: ConnectionLostRetryPolicy())
    
    init(additionalHeaders: NetworkDefaultHeaders?) {
        self.additionalHeaders = additionalHeaders
    }
    
    func execute<T: Request>(request: NetworkProviderRequest<T>,
                             uploadProgress: ProgressHandler?,
                             completion: @escaping (URLResponse?, Data?, NetworkProviderError?) -> Void)
            -> Cancellable? {
        var urlRequest: URLRequest
        do {
            urlRequest = try request.urlRequest()
        } catch let error {
            completion(nil, nil, .other(error: error))
            return nil
        }
        
        additionalHeaders?.headersDictionary.forEach {
            urlRequest.setValue($0.value, forHTTPHeaderField: $0.key)
        }
                
        var afRequest: DataRequest
        switch request.body {
        case .multipartData(let dataParts):
            let multipartFormData = MultipartFormData()
            multipartFormData.append(dataParts)
            afRequest = session.upload(multipartFormData: multipartFormData, with: urlRequest)
        case .parameters, .none:
            afRequest = session.request(urlRequest)
        }
        
        if let uploadProgress = uploadProgress {
            afRequest = afRequest.uploadProgress(closure: uploadProgress)
        }
        
        afRequest = afRequest
            .validate(statusCode: 200..<300)
            .responseJSON(queue: responseQueue) { response in
                let error = response.error.map { NetworkProviderError(afError: $0) }
                completion(response.response, response.data, error)
        }

        return AlamofireDataRequest(dataRequest: afRequest)
    }
}
