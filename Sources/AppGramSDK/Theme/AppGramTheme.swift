import SwiftUI

/// Represents a theme configuration for AppGram SDK views.
///
/// ## Discussion
/// Themes allow you to customize the appearance of all SDK views by defining
/// color palettes for light and dark modes. The SDK includes several built-in
/// themes, or you can create custom themes.
///
/// ## Example
/// ```swift
/// let theme = AppGramTheme(
///     colors: .modern,
///     darkColors: .modernDark
/// )
/// AppGramSDK.shared.configure(projectId: "project123", theme: theme)
/// ```
public struct AppGramTheme: Sendable {
    /// The color palette for light mode.
    public let colors: ColorPalette
    
    /// The optional color palette for dark mode.
    public let darkColors: ColorPalette?

    public init(colors: ColorPalette, darkColors: ColorPalette? = nil) {
        self.colors = colors
        self.darkColors = darkColors
    }

    public static let `default` = AppGramTheme(
        colors: .modern,
        darkColors: .modernDark
    )

    public static let ocean = AppGramTheme(colors: .ocean)
    public static let forest = AppGramTheme(colors: .forest)
    public static let sunset = AppGramTheme(colors: .sunset)
    public static let minimal = AppGramTheme(colors: .minimal)
    public static let classic = AppGramTheme(colors: .classic)
    public static let slate = AppGramTheme(colors: .slate)
    public static let neutral = AppGramTheme(colors: .neutral)

    public func resolvedColors(for colorScheme: ColorScheme) -> ColorPalette {
        if colorScheme == .dark, let darkColors = darkColors {
            return darkColors
        }
        return colors
    }
}

public struct ThemeEnvironmentKey: EnvironmentKey {
    public static let defaultValue: AppGramTheme = .default
}

extension EnvironmentValues {
    public var appGramTheme: AppGramTheme {
        get { self[ThemeEnvironmentKey.self] }
        set { self[ThemeEnvironmentKey.self] = newValue }
    }
}

extension View {
    public func appGramTheme(_ theme: AppGramTheme) -> some View {
        environment(\.appGramTheme, theme)
    }
}
