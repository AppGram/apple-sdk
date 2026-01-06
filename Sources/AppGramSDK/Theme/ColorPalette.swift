import SwiftUI

/// Represents a color palette for AppGram SDK views.
///
/// ## Discussion
/// Color palettes define all the colors used throughout the SDK views, including
/// primary colors, backgrounds, text colors, semantic colors, and neutral colors
/// for shadcn-style subtle borders and backgrounds.
///
/// ## Example
/// ```swift
/// let palette = ColorPalette(
///     primary: .blue,
///     secondary: .gray,
///     accent: .purple,
///     background: .white,
///     text: .black,
///     cardBackground: .white,
///     cardText: .black,
///     border: .gray.opacity(0.2)
/// )
/// ```
public struct ColorPalette: Sendable {
    /// The primary brand color.
    public let primary: Color

    /// The secondary brand color.
    public let secondary: Color

    /// The accent color for highlights.
    public let accent: Color

    /// The main background color.
    public let background: Color

    /// The primary text color.
    public let text: Color

    /// The background color for cards.
    public let cardBackground: Color

    /// The text color for cards.
    public let cardText: Color

    /// The border color.
    public let border: Color

    /// The color for success states.
    public let success: Color

    /// The color for warning states.
    public let warning: Color

    /// The color for error states.
    public let error: Color

    // MARK: - Neutral Color Scale (shadcn-inspired)

    /// Lightest neutral background (50)
    public let neutral50: Color

    /// Light neutral background (100)
    public let neutral100: Color

    /// Subtle border color (200) - Most commonly used for borders
    public let neutral200: Color

    /// Medium border color (300)
    public let neutral300: Color

    /// Muted text color (400)
    public let neutral400: Color

    /// Secondary text color (500)
    public let neutral500: Color

    /// Primary text color (600)
    public let neutral600: Color

    /// Emphasized text color (700)
    public let neutral700: Color

    /// Dark background (800)
    public let neutral800: Color

    /// Darkest background (900)
    public let neutral900: Color

    public init(
        primary: Color,
        secondary: Color,
        accent: Color,
        background: Color,
        text: Color,
        cardBackground: Color,
        cardText: Color,
        border: Color,
        success: Color = Color(hex: "#10b981"),
        warning: Color = Color(hex: "#f59e0b"),
        error: Color = Color(hex: "#ef4444"),
        // Neutral colors (shadcn-style)
        neutral50: Color = Color(hex: "#fafafa"),
        neutral100: Color = Color(hex: "#f5f5f5"),
        neutral200: Color = Color(hex: "#e5e5e5"),
        neutral300: Color = Color(hex: "#d4d4d4"),
        neutral400: Color = Color(hex: "#a3a3a3"),
        neutral500: Color = Color(hex: "#737373"),
        neutral600: Color = Color(hex: "#525252"),
        neutral700: Color = Color(hex: "#404040"),
        neutral800: Color = Color(hex: "#262626"),
        neutral900: Color = Color(hex: "#171717")
    ) {
        self.primary = primary
        self.secondary = secondary
        self.accent = accent
        self.background = background
        self.text = text
        self.cardBackground = cardBackground
        self.cardText = cardText
        self.border = border
        self.success = success
        self.warning = warning
        self.error = error
        self.neutral50 = neutral50
        self.neutral100 = neutral100
        self.neutral200 = neutral200
        self.neutral300 = neutral300
        self.neutral400 = neutral400
        self.neutral500 = neutral500
        self.neutral600 = neutral600
        self.neutral700 = neutral700
        self.neutral800 = neutral800
        self.neutral900 = neutral900
    }
}

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
