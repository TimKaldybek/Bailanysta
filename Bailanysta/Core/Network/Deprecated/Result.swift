//
//  Result.swift
//  Alamofire
//
//  Created by Amirzhan on 12.06.2018.
//

/// Результат запроса
public enum Result<T> {
    case success(T)
    case failure(DeprecatedNetworkError)
}
