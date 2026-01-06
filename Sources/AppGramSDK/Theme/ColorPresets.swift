import SwiftUI

extension ColorPalette {
    // MARK: - Existing Presets (Updated with Neutral Colors)

    public static let modern = ColorPalette(
        primary: Color(hex: "#6366f1"),
        secondary: Color(hex: "#8b5cf6"),
        accent: Color(hex: "#10b981"),
        background: Color(hex: "#ffffff"),
        text: Color(hex: "#1f2937"),
        cardBackground: Color(hex: "#f9fafb"),
        cardText: Color(hex: "#374151"),
        border: Color(hex: "#e5e7eb"),
        neutral200: Color(hex: "#e5e7eb")
    )

    public static let modernDark = ColorPalette(
        primary: Color(hex: "#818cf8"),
        secondary: Color(hex: "#a78bfa"),
        accent: Color(hex: "#34d399"),
        background: Color(hex: "#111827"),
        text: Color(hex: "#f9fafb"),
        cardBackground: Color(hex: "#1f2937"),
        cardText: Color(hex: "#e5e7eb"),
        border: Color(hex: "#374151"),
        neutral200: Color(hex: "#374151")
    )

    public static let ocean = ColorPalette(
        primary: Color(hex: "#0ea5e9"),
        secondary: Color(hex: "#06b6d4"),
        accent: Color(hex: "#14b8a6"),
        background: Color(hex: "#ffffff"),
        text: Color(hex: "#0f172a"),
        cardBackground: Color(hex: "#f0f9ff"),
        cardText: Color(hex: "#1e293b"),
        border: Color(hex: "#e0f2fe"),
        neutral200: Color(hex: "#e0f2fe")
    )

    public static let forest = ColorPalette(
        primary: Color(hex: "#22c55e"),
        secondary: Color(hex: "#16a34a"),
        accent: Color(hex: "#84cc16"),
        background: Color(hex: "#ffffff"),
        text: Color(hex: "#14532d"),
        cardBackground: Color(hex: "#f0fdf4"),
        cardText: Color(hex: "#166534"),
        border: Color(hex: "#dcfce7"),
        neutral200: Color(hex: "#dcfce7")
    )

    public static let sunset = ColorPalette(
        primary: Color(hex: "#f97316"),
        secondary: Color(hex: "#ef4444"),
        accent: Color(hex: "#f59e0b"),
        background: Color(hex: "#ffffff"),
        text: Color(hex: "#7c2d12"),
        cardBackground: Color(hex: "#fff7ed"),
        cardText: Color(hex: "#9a3412"),
        border: Color(hex: "#fed7aa"),
        neutral200: Color(hex: "#fed7aa")
    )

    public static let minimal = ColorPalette(
        primary: Color(hex: "#18181b"),
        secondary: Color(hex: "#27272a"),
        accent: Color(hex: "#3f3f46"),
        background: Color(hex: "#ffffff"),
        text: Color(hex: "#18181b"),
        cardBackground: Color(hex: "#fafafa"),
        cardText: Color(hex: "#27272a"),
        border: Color(hex: "#e4e4e7"),
        neutral200: Color(hex: "#e4e4e7")
    )

    public static let classic = ColorPalette(
        primary: Color(hex: "#2563eb"),
        secondary: Color(hex: "#1d4ed8"),
        accent: Color(hex: "#3b82f6"),
        background: Color(hex: "#ffffff"),
        text: Color(hex: "#1e3a5f"),
        cardBackground: Color(hex: "#eff6ff"),
        cardText: Color(hex: "#1e40af"),
        border: Color(hex: "#dbeafe"),
        neutral200: Color(hex: "#dbeafe")
    )

    // MARK: - New Presets (Shadcn Minimal Aesthetic)

    /// Slate preset - shadcn minimal aesthetic with slate gray tones
    public static let slate = ColorPalette(
        primary: Color(hex: "#0f172a"),
        secondary: Color(hex: "#334155"),
        accent: Color(hex: "#64748b"),
        background: Color(hex: "#ffffff"),
        text: Color(hex: "#0f172a"),
        cardBackground: Color(hex: "#f8fafc"),
        cardText: Color(hex: "#1e293b"),
        border: Color(hex: "#e2e8f0"),
        neutral200: Color(hex: "#e2e8f0"),
        neutral300: Color(hex: "#cbd5e1"),
        neutral400: Color(hex: "#94a3b8"),
        neutral500: Color(hex: "#64748b"),
        neutral600: Color(hex: "#475569"),
        neutral700: Color(hex: "#334155"),
        neutral800: Color(hex: "#1e293b"),
        neutral900: Color(hex: "#0f172a")
    )

    /// Neutral preset - pure minimal design with neutral gray scale
    public static let neutral = ColorPalette(
        primary: Color(hex: "#171717"),
        secondary: Color(hex: "#404040"),
        accent: Color(hex: "#737373"),
        background: Color(hex: "#ffffff"),
        text: Color(hex: "#171717"),
        cardBackground: Color(hex: "#fafafa"),
        cardText: Color(hex: "#262626"),
        border: Color(hex: "#e5e5e5"),
        neutral50: Color(hex: "#fafafa"),
        neutral100: Color(hex: "#f5f5f5"),
        neutral200: Color(hex: "#e5e5e5"),
        neutral300: Color(hex: "#d4d4d4"),
        neutral400: Color(hex: "#a3a3a3"),
        neutral500: Color(hex: "#737373"),
        neutral600: Color(hex: "#525252"),
        neutral700: Color(hex: "#404040"),
        neutral800: Color(hex: "#262626"),
        neutral900: Color(hex: "#171717")
    )
}
