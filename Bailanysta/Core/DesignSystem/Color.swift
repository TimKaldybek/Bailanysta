//
//  Color.swift
//  Bailanysta
//

import UIKit

/// The app's single source of truth for color. Every color used in the UI must come from here —
/// see the "Design system" rule in CLAUDE.md.
///
/// Values are sourced from the "Indigo Evolved" light/dark palettes. Each semantic token is a
/// dynamic `UIColor` that resolves against `UITraitCollection.userInterfaceStyle`, so switching
/// `ThemeManager`'s theme (or the system appearance) updates every screen automatically — no
/// call site ever branches on light/dark itself.
enum Color {

    // MARK: - Brand

    /// Main brand accent — CTAs, active tab/segment states, key highlights.
    static let primary = dynamic(light: primaryLight, dark: primaryDark)

    /// Secondary brand accent — gradients and highlights that pair with `primary`.
    static let tertiary = dynamic(light: tertiaryLight, dark: tertiaryDark)

    /// Low-opacity tint of `primary` — pills, chips, avatar placeholders, selected backgrounds.
    static let primaryMuted = dynamic(
        light: primaryLight.withAlphaComponent(0.12),
        dark: primaryDark.withAlphaComponent(0.18)
    )

    /// Foreground for content drawn on top of `primary`/`tertiary` (e.g. button titles/icons).
    static let onPrimary = UIColor.white

    // MARK: - Surfaces

    /// Screen background.
    static let background = dynamic(light: secondaryLight, dark: secondaryDark)

    /// Elevated surface — cards, sheets, the tab bar.
    static let surface = dynamic(
        light: .white,
        dark: secondaryDark.blended(with: .white, amount: 0.08)
    )

    // MARK: - Text

    static let label = dynamic(light: neutral, dark: .white)

    static let labelSecondary = dynamic(
        light: neutral.withAlphaComponent(0.6),
        dark: UIColor.white.withAlphaComponent(0.6)
    )

    static let labelTertiary = dynamic(
        light: neutral.withAlphaComponent(0.4),
        dark: UIColor.white.withAlphaComponent(0.4)
    )

    // MARK: - Strokes & shadows

    /// Hairline borders and separators.
    static let divider = dynamic(
        light: neutral.withAlphaComponent(0.08),
        dark: UIColor.white.withAlphaComponent(0.12)
    )

    /// Layer shadow color — pair with a per-view `shadowOpacity`, this token is fully opaque.
    static let shadow = dynamic(light: neutral, dark: .black)

    // MARK: - Decorative icon accents (e.g. the Settings list)

    static let accentBlue = UIColor.systemBlue
    static let accentGreen = UIColor.systemGreen
    static let accentRed = UIColor.systemRed
    static let accentIndigo = UIColor.systemIndigo

    // MARK: - Indigo Evolved palette

    /// Fixed neutral anchor of the palette (#0F0E1E). Theme-agnostic — use `label`/`background`
    /// for anything that should adapt between light and dark instead of this directly.
    static let neutral = UIColor(hex: 0x0F0E1E)

    private static let primaryLight = UIColor(hex: 0x6625F6)
    private static let primaryDark = UIColor(hex: 0x9463FF)
    private static let tertiaryLight = UIColor(hex: 0x9463FF)
    private static let tertiaryDark = UIColor(hex: 0x6625F6)
    private static let secondaryLight = UIColor(hex: 0xF0EFFF)
    private static let secondaryDark = UIColor(hex: 0x1A1926)

    private static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { traits in
            traits.userInterfaceStyle == .dark ? dark : light
        }
    }
}

private extension UIColor {
    /// Linearly interpolates towards `color` in RGB space. Only meaningful for non-dynamic
    /// (fixed) colors — used here to derive elevated surfaces from the base palette tones.
    func blended(with color: UIColor, amount: CGFloat) -> UIColor {
        var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
        var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0
        getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
        color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

        return UIColor(
            red: r1 + (r2 - r1) * amount,
            green: g1 + (g2 - g1) * amount,
            blue: b1 + (b2 - b1) * amount,
            alpha: a1 + (a2 - a1) * amount
        )
    }
}
