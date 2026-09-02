//
//  AlamofireDataRequest.swift
//  Network
//
//  Created by Islam Temirbek on 7/19/18.
//

import Alamofire

/// Класс-оболочка для иницилизации запроса, который следует протоколу Cancelable
struct AlamofireDataRequest: Cancellable {
    private weak var dataRequest: DataRequest?
    
    /// Иницилазация запроса для отмены
    init(dataRequest: DataRequest) {
        self.dataRequest = dataRequest
    }
    
    public func cancel() {
        dataRequest?.cancel()
    }
    
    public func isFinished() -> Bool {
        dataRequest == nil
    }
}
