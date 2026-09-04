//
//  AuthInteractor.swift
//  Bailanysta
//

final class AuthInteractor {
    private let dataProvider: AuthDataProvider

    init(dataProvider: AuthDataProvider) {
        self.dataProvider = dataProvider
    }

    func signIn(email: String, password: String) async throws -> AuthUser {
        try await dataProvider.signIn(email: email, password: password)
    }

    func signUp(email: String, password: String, name: String, handle: String) async throws -> AuthUser {
        try await dataProvider.signUp(email: email, password: password, name: name, handle: handle)
    }

    func signInWithGoogle(idToken: String, accessToken: String, name: String, email: String) async throws -> AuthUser {
        try await dataProvider.signInWithGoogle(idToken: idToken, accessToken: accessToken, name: name, email: email)
    }
}
