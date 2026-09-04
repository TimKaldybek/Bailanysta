//
//  SessionManager.swift
//  Bailanysta
//

import FirebaseAuth
import Foundation

extension Notification.Name {
    static let userDidSignOut = Notification.Name("userDidSignOut")
}

/// Thin wrapper around `FirebaseAuth.Auth` exposing the minimum the app needs to know about the
/// current session. Sign-in/sign-up business logic lives in the `Auth` module's Data/Domain
/// layers — this is only session state, mirroring `ThemeManager`'s singleton shape.
final class SessionManager {
    static let shared = SessionManager()

    private let auth: Auth

    private init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }

    /// `true` for anonymous users too — an anonymous Firebase user still counts as "signed in".
    var isSignedIn: Bool {
        auth.currentUser != nil
    }

    var currentUserID: String? {
        auth.currentUser?.uid
    }

    func signOut() throws {
        try auth.signOut()
        NotificationCenter.default.post(name: .userDidSignOut, object: nil)
    }
}
