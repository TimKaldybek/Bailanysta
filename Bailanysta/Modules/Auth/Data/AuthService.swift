//
//  AuthService.swift
//  Bailanysta
//

import FirebaseAuth
import FirebaseFirestore

/// Wraps the Firebase Auth/Firestore SDK calls directly — the "network/SDK call" Service. Maps
/// `FirebaseAuth.User` into a plain `AuthUserDTO`; `FirebaseAuth.User` never leaves this file.
final class AuthService {
    private let auth: Auth
    private let firestore: Firestore

    init(auth: Auth = Auth.auth(), firestore: Firestore = Firestore.firestore()) {
        self.auth = auth
        self.firestore = firestore
    }

    func signIn(email: String, password: String) async throws -> AuthUserDTO {
        let result = try await auth.signIn(withEmail: email, password: password)
        return Self.map(result.user)
    }

    func signUp(email: String, password: String, name: String, handle: String) async throws -> AuthUserDTO {
        let result = try await auth.createUser(withEmail: email, password: password)
        try await writeUserDocument(uid: result.user.uid, name: name, handle: handle, email: email)
        return Self.map(result.user)
    }

    func signInWithGoogle(idToken: String, accessToken: String, name: String, email: String) async throws -> AuthUserDTO {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        let result = try await auth.signIn(with: credential)

        let documentSnapshot = try await firestore.collection(Constants.usersCollection).document(result.user.uid).getDocument()
        if !documentSnapshot.exists {
            let handle = Self.defaultHandle(fromEmail: email)
            try await writeUserDocument(uid: result.user.uid, name: name, handle: handle, email: email)
        }

        return Self.map(result.user)
    }
}

// MARK: - Private

private extension AuthService {
    func writeUserDocument(uid: String, name: String, handle: String, email: String) async throws {
        let data: [String: Any] = [
            "name": name,
            "handle": handle,
            "email": email,
            "createdAt": FieldValue.serverTimestamp()
        ]
        try await firestore.collection(Constants.usersCollection).document(uid).setData(data)
    }

    static func defaultHandle(fromEmail email: String) -> String {
        let localPart = email.split(separator: "@").first.map(String.init) ?? email
        return "@\(localPart)"
    }

    static func map(_ user: User) -> AuthUserDTO {
        AuthUserDTO(uid: user.uid, email: user.email, isAnonymous: user.isAnonymous)
    }
}

// MARK: - Constants

private extension AuthService {
    enum Constants {
        static let usersCollection = "users"
    }
}
