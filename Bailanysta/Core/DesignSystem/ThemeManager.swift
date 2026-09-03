//
//  ThemeManager.swift
//  Bailanysta
//

import UIKit

/// Owns the app's current `AppTheme`, persists it, and applies it to every window.
///
/// `Color`'s tokens are all dynamic `UIColor`s, so calling `apply(_:)` is enough to re-theme
/// the entire UI — no view needs to observe theme changes itself.
final class ThemeManager {
    static let shared = ThemeManager()

    @Locked private var theme: AppTheme

    private let defaults: UserDefaults
    private let storageKey = "com.bailanysta.designSystem.appTheme"

    private init(defaults: UserDefaults = .standard) {
        self.defaults = defaults

        if let rawValue = defaults.string(forKey: storageKey), let storedTheme = AppTheme(rawValue: rawValue) {
            theme = storedTheme
        } else {
            theme = .system
        }
    }

    var currentTheme: AppTheme {
        theme
    }

    /// Persists `theme` and immediately restyles every connected window.
    func apply(_ theme: AppTheme) {
        self.theme = theme
        defaults.set(theme.rawValue, forKey: storageKey)

        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .forEach { $0.overrideUserInterfaceStyle = theme.userInterfaceStyle }
    }

    /// Applies the persisted theme to a window as it's created (app launch).
    func applyStoredTheme(to window: UIWindow) {
        window.overrideUserInterfaceStyle = theme.userInterfaceStyle
    }
}
