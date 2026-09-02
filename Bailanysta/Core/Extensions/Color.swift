//
//  Color.swift
//  Kolesa Team
//
//  Created by Timur Kaldybek on 08.11.2024.
//

import Foundation
import UIKit

public final class Color {

    // MARK: - Main

    public static let primary = UIColor(hex: 0x7B3FF2)
    public static let primaryAlt = UIColor(hex: 0x9B6BFF)
    public static let secondary = UIColor(hex: 0x1A1430)

    public static let background = UIColor(hex: 0x0B0A13)      // FIXED
    public static let backgroundAlt = UIColor(hex: 0x151022)   // FIXED

    public static let stroke = UIColor(hex: 0x2A2440)
    public static let text = UIColor(hex: 0xFFFFFF)

    // MARK: - Dark (оставил, но можно удалить если не используешь)

    public static let primaryDark = UIColor(hex: 0x5A2DBF)
    public static let primaryAltDark = UIColor(hex: 0x7B3FF2)
    public static let secondaryDark = UIColor(hex: 0x1A1430)
    public static let backgroundDark = UIColor(hex: 0x0B0A13)
    public static let backgroundAltDark = UIColor(hex: 0x151022)
    public static let strokeDark = UIColor(hex: 0x2A2440)
    public static let textDark = UIColor(hex: 0xFFFFFF)

    // MARK: - Neutral (ВАЖНО: вернул твои)

    public static let textButton = UIColor(hex: 0xFFFFFF)
    public static let textSecondary = UIColor(hex: 0xB3B0C3)

    // MARK: - Additional (из дизайна)

    public static let textTertiary = UIColor(hex: 0x7A768F)
    public static let cardBackground = UIColor(hex: 0x17132A)

    public static let accentPurple = UIColor(hex: 0xA66CFF)
    public static let accentIndigo = UIColor(hex: 0x6E44FF)

    // Gradient кнопок
    public static let buttonGradientStart = UIColor(hex: 0x7B3FF2)
    public static let buttonGradientEnd = UIColor(hex: 0xA66CFF)
}
