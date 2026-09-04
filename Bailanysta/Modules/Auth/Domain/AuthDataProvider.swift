//
//  AuthDataProvider.swift
//  Bailanysta
//

struct AuthDataProvider {
    private let service: AuthService

    init(service: AuthService) {
        self.service = service
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        let dto = try await service.signIn(email: email, password: password)
        return Self.map(dto)
    }

    func signUp(email: String, password: String, name: String, handle: String) async throws -> AuthUser {
        let dto = try await service.signUp(email: email, password: password, name: name, handle: handle)
        return Self.map(dto)
    }

    func signInWithGoogle(idToken: String, accessToken: String, name: String, email: String) async throws -> AuthUser {
        let dto = try await service.signInWithGoogle(idToken: idToken, accessToken: accessToken, name: name, email: email)
        return Self.map(dto)
    }

    private static func map(_ dto: AuthUserDTO) -> AuthUser {
        AuthUser(uid: dto.uid, email: dto.email, isAnonymous: dto.isAnonymous)
    }
}
