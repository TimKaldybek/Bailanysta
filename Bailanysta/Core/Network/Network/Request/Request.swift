//
//  Request.swift
//  KKNetwork
//
//  Created by Timur Tabynbayev on 05.02.2021.
//

import Foundation
import Alamofire

/// Протокол для запросов в любой API.
///
/// Предполагается использование для обычных и для upload запросов. Download запросам нужен другой интерфейс, поэтому
/// потом заведём отдельный протокол для них.
///
/// Запросы, следующие этому протоколу, необходимо выполнять через класс Network.
public protocol Request {
    /// Тип ответа. Network.execute(request:completion:) вернёт в completion объект этого типа. Если тип не
    /// следует протоколу Decodable и не является типом Data, то необходимо реализовать метод parseSuccess(data:)
    associatedtype ResponseType
    
    /// Тип Environment. Дженерик нужен для того, чтобы вытаскивать тип ошибки.
    /// Задавать через typealias не нужно, он определяется через реализацию переменной environment.
    associatedtype EnvironmentType: Environment
    
    /// Тип ошибки бэка. То, что парсится из ответа сервера. По умолчанию берётся из EnvironmentType, но можно задавать
    /// отдельно для запроса через typealias.
    associatedtype EndpointErrorType: EndpointError = EnvironmentType.EndpointErrorType
    
    /// Из environment берутся общие данные для запросов в один API: хост, дефолтные заголовки, параметры в query и т.д.
    var environment: EnvironmentType { get }
    
    /// url-путь запроса
    ///
    /// Корректно работает и при наличии, и при отсутствии слэша в начале. Но рекомендуется ставить в начале слэш.
    var path: String { mutating get }
    
    /// HTTP метод запроса
    var method: HTTPMethod { mutating get }
    
    /// Словарь заголовков, добавляемый в заголовки запроса вместе с заголовками из environment.
    var headers: HTTPHeaders? { mutating get }
    
    /// Словарь параметров, добавляемый в query запроса вместе с query параметра из environment.
    var query: Parameters? { mutating get }
    
    /// Можно задать либо словарь параметров, либо multipartFormData. Во втором случае будет использован upload.
    var body: Body? { mutating get }
    
    /// По умолчанию берётся из environment, но если нужно сделать кастомный для одного запроса,
    /// то можно определить здесь.
    var bodyRepresentation: BodyRepresentation? { mutating get }
    
    /// Метод парсинга успешного ответа от сервера в Result<ResponseType>. Находится в протоколе Request, потому что
    /// раз он задаёт тип ответа от бэка и тип ошибок, то пусть и парсит их. Так выходит и удобнее
    /// для кода внутри Network.
    ///
    /// Есть реализации по умолчанию:
    /// - для ResponseType, которые следует Decodable. В этом случае сначала идёт попытка парсинга ResponseType из
    /// data. Если не получилось, то идёт попытка парсинга EndpointErrorType. Если не получилось, то возвращается
    /// ошибка incorrectFormat.
    /// - для ResponseType, которые является типом Data. В этом случае сначала идёт попытка парсинга EndpointErrorType.
    /// Если не получилось, то возвращается .success(data)
    static func parseSuccess(data: Data) -> NetworkResult<ResponseType>
    
    /// Метод парсинга ошибочного ответа от сервера в Result<ResponseType>. Находится в протоколе Request, потому что
    /// раз он задаёт тип ответа от бэка и тип ошибок, то пусть и парсит их. Так выходит и удобнее
    /// для кода внутри Network.
    ///
    /// Есть реализацию по умолчанию. В ней идёт попытка парсинга EndpointErrorType из data (на случай если бэк вернул
    /// в теле ответа ошибку, а код ответа не 2xx). Если не получилось то возвращается error.
    static func parseFailure(data: Data, error: NetworkProviderError) -> NetworkResult<ResponseType>
}

public extension Request {
    var method: HTTPMethod {
        .get
    }
    
    var headers: HTTPHeaders? {
        nil
    }
    
    var query: Parameters? {
        nil
    }
    
    var body: Body? {
        nil
    }
    
    var bodyRepresentation: BodyRepresentation? {
        nil
    }
}
