//
//  NetworkService.swift
//  Bailanysta
//

import Foundation
import Alamofire

protocol NetworkServiceProtocol {
    func get<Response: Decodable>(path: String, parameters: [String: Any]?) async throws -> Response
    func post<Response: Decodable>(path: String, parameters: [String: Any]?) async throws -> Response
}

extension NetworkServiceProtocol {
    func get<Response: Decodable>(path: String) async throws -> Response {
        try await get(path: path, parameters: nil)
    }

    func post<Response: Decodable>(path: String) async throws -> Response {
        try await post(path: path, parameters: nil)
    }
}

final class NetworkService: NetworkServiceProtocol {
    private let baseURL: URL
    private let session: Session

    init(baseURL: URL, session: Session = .default) {
        self.baseURL = baseURL
        self.session = session
    }

    func get<Response: Decodable>(path: String, parameters: [String: Any]? = nil) async throws -> Response {
        try await request(path: path, method: .get, encoding: URLEncoding.default, parameters: parameters)
    }

    func post<Response: Decodable>(path: String, parameters: [String: Any]? = nil) async throws -> Response {
        try await request(path: path, method: .post, encoding: JSONEncoding.default, parameters: parameters)
    }

    private func request<Response: Decodable>(
        path: String,
        method: HTTPMethod,
        encoding: ParameterEncoding,
        parameters: [String: Any]?
    ) async throws -> Response {
        try await session
            .request(baseURL.appendingPathComponent(path), method: method, parameters: parameters, encoding: encoding)
            .validate()
            .serializingDecodable(Response.self)
            .value
    }
}
