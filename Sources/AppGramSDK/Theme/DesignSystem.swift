import SwiftUI

/// Design system constants based on shadcn principles.
///
/// ## Overview
/// The AppGramSDK design system provides a unified set of constants for spacing, typography,
/// animations, shadows, and colors. It combines the minimal aesthetic of shadcn/ui from the web
/// with native iOS design patterns.
///
/// ## Usage
/// ```swift
/// VStack(spacing: DesignSystem.Spacing.lg) {
///     Text("Hello")
///         .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.semibold))
///         .padding(DesignSystem.Spacing.md)
/// }
/// .background(colors.cardBackground)
/// .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
/// .shadowStyle(DesignSystem.Shadow.sm)
/// ```
///
/// ## Design Principles
/// - **Shadcn**: Subtle borders, soft shadows, consistent spacing, refined typography, minimal aesthetic
/// - **Native iOS**: Smooth animations, natural feel, accessibility support
public struct DesignSystem {

    // MARK: - Spacing Scale (shadcn-inspired, iOS-adapted)

    /// Spacing constants following a consistent scale (4px base).
    ///
    /// Use these instead of hardcoded values to maintain visual rhythm throughout your UI.
    ///
    /// ## Example
    /// ```swift
    /// VStack(spacing: DesignSystem.Spacing.lg) {
    ///     Text("Title")
    ///         .padding(.horizontal, DesignSystem.Spacing.xl)
    /// }
    /// ```
    public struct Spacing {
        /// Extra small spacing (4pt) - Tiny gaps, badge padding
        public static let xs: CGFloat = 4

        /// Small spacing (8pt) - Small spacing, icon gaps
        public static let sm: CGFloat = 8

        /// Medium spacing (12pt) - Medium spacing, text gaps
        public static let md: CGFloat = 12

        /// Large spacing (16pt) - Default padding, most common
        public static let lg: CGFloat = 16

        /// Extra large spacing (24pt) - Section spacing
        public static let xl: CGFloat = 24

        /// Extra extra large spacing (32pt) - Large sections
        public static let xxl: CGFloat = 32

        /// Extra extra extra large spacing (48pt) - Major sections
        public static let xxxl: CGFloat = 48

        private init() {}
    }

    // MARK: - Typography Scale (shadcn-inspired)

    /// Typography constants for font sizes, line heights, and weights.
    ///
    /// Provides a consistent type scale throughout the SDK.
    ///
    /// ## Example
    /// ```swift
    /// Text("Headline")
    ///     .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.semibold))
    ///     .lineSpacing(DesignSystem.Typography.xl * DesignSystem.Typography.lineHeightNormal - DesignSystem.Typography.xl)
    /// ```
    public struct Typography {
        // Font sizes
        /// Extra small font size (12pt) - Captions, fine print
        public static let xs: CGFloat = 12

        /// Small font size (14pt) - Secondary text
        public static let sm: CGFloat = 14

        /// Base font size (16pt) - Body text, default
        public static let base: CGFloat = 16

        /// Large font size (18pt) - Subheadings
        public static let lg: CGFloat = 18

        /// Extra large font size (20pt) - Headings
        public static let xl: CGFloat = 20

        /// Extra extra large font size (24pt) - Large headings
        public static let xxl: CGFloat = 24

        /// Extra extra extra large font size (32pt) - Hero text
        public static let xxxl: CGFloat = 32

        // Line heights (multipliers)
        /// Tight line height (1.25x) - Compact text
        public static let lineHeightTight: CGFloat = 1.25

        /// Normal line height (1.5x) - Standard body text
        public static let lineHeightNormal: CGFloat = 1.5

        /// Relaxed line height (1.75x) - Comfortable reading
        public static let lineHeightRelaxed: CGFloat = 1.75

        // Font weights
        /// Regular font weight
        public static let regular: Font.Weight = .regular

        /// Medium font weight
        public static let medium: Font.Weight = .medium

        /// Semibold font weight
        public static let semibold: Font.Weight = .semibold

        /// Bold font weight
        public static let bold: Font.Weight = .bold

        private init() {}
    }

    // MARK: - Corner Radius (consistent scale)

    /// Corner radius constants for consistent rounded corners.
    ///
    /// ## Example
    /// ```swift
    /// RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
    /// ```
    public struct CornerRadius {
        /// Extra small corner radius (4pt) - Badges
        public static let xs: CGFloat = 4

        /// Small corner radius (6pt) - Small buttons
        public static let sm: CGFloat = 6

        /// Medium corner radius (8pt) - Form fields
        public static let md: CGFloat = 8

        /// Large corner radius (12pt) - Cards, buttons (most common)
        public static let lg: CGFloat = 12

        /// Extra large corner radius (16pt) - Large cards
        public static let xl: CGFloat = 16

        /// Extra extra large corner radius (20pt) - Sheets, modals
        public static let xxl: CGFloat = 20

        /// Pill corner radius (999pt) - Capsule shapes
        public static let pill: CGFloat = 999

        private init() {}
    }

    // MARK: - Border Width (subtle, shadcn-style)

    /// Border width constants for subtle borders.
    ///
    /// Shadcn design philosophy emphasizes minimal, barely-visible borders.
    ///
    /// ## Example
    /// ```swift
    /// RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
    ///     .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
    /// ```
    public struct BorderWidth {
        /// Hairline border (0.5pt) - Ultra-subtle separation
        public static let hairline: CGFloat = 0.5

        /// Thin border (1pt) - Standard border (most common)
        public static let thin: CGFloat = 1

        /// Medium border (1.5pt) - Emphasized border
        public static let medium: CGFloat = 1.5

        /// Thick border (2pt) - Strong border
        public static let thick: CGFloat = 2

        private init() {}
    }

    // MARK: - Shadow Styles (soft, layered elevation)

    /// Shadow style definition with color, radius, and offset.
    public struct ShadowStyle {
        public let color: Color
        public let radius: CGFloat
        public let x: CGFloat
        public let y: CGFloat

        public init(color: Color, radius: CGFloat, x: CGFloat, y: CGFloat) {
            self.color = color
            self.radius = radius
            self.x = x
            self.y = y
        }
    }

    /// Shadow constants for subtle elevation effects.
    ///
    /// Shadows use low opacity to create depth without heaviness.
    ///
    /// ## Example
    /// ```swift
    /// CardView()
    ///     .shadowStyle(DesignSystem.Shadow.sm)
    /// ```
    public struct Shadow {
        /// No shadow
        public static let none = ShadowStyle(color: .clear, radius: 0, x: 0, y: 0)

        /// Extra small shadow - Minimal elevation (radius: 2, y: 1, opacity: 0.04)
        public static let xs = ShadowStyle(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)

        /// Small shadow - Subtle elevation (radius: 4, y: 2, opacity: 0.06)
        public static let sm = ShadowStyle(color: Color.black.opacity(0.06), radius: 4, x: 0, y: 2)

        /// Medium shadow - Standard cards (radius: 8, y: 4, opacity: 0.08)
        public static let md = ShadowStyle(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)

        /// Large shadow - Prominent elements (radius: 12, y: 6, opacity: 0.10)
        public static let lg = ShadowStyle(color: Color.black.opacity(0.10), radius: 12, x: 0, y: 6)

        /// Extra large shadow - Floating elements (radius: 16, y: 8, opacity: 0.12)
        public static let xl = ShadowStyle(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)

        private init() {}
    }

    // MARK: - Animation Constants

    /// Animation constants for smooth, natural transitions.
    ///
    /// Based on shadcn's 150-200ms timing and iOS 26's spring curves.
    ///
    /// ## Example
    /// ```swift
    /// Button("Tap me")
    ///     .scaleEffect(isPressed ? 0.97 : 1.0)
    ///     .animation(DesignSystem.Animation.spring, value: isPressed)
    /// ```
    public struct Animation {
        // Durations (shadcn-inspired: 150-200ms)
        /// Instant animation (0.1s) - Very quick state changes
        public static let instant: Double = 0.1

        /// Fast animation (0.15s) - Quick state changes
        public static let fast: Double = 0.15

        /// Normal animation (0.2s) - Standard transitions (most common)
        public static let normal: Double = 0.2

        /// Slow animation (0.3s) - Deliberate animations
        public static let slow: Double = 0.3

        /// Slower animation (0.4s) - Complex animations
        public static let slower: Double = 0.4

        // Spring curves (iOS 26 natural feel)
        /// Standard spring animation - Balanced and versatile
        public static let spring = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7, blendDuration: 0)

        /// Bouncy spring animation - Playful and energetic
        public static let springBouncy = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.6, blendDuration: 0)

        /// Smooth spring animation - Elegant and refined
        public static let springSmooth = SwiftUI.Animation.spring(response: 0.35, dampingFraction: 0.8, blendDuration: 0)

        // Easing curves
        /// Ease in animation - Starts slow, ends fast
        public static let easeIn = SwiftUI.Animation.easeIn(duration: normal)

        /// Ease out animation - Starts fast, ends slow
        public static let easeOut = SwiftUI.Animation.easeOut(duration: normal)

        /// Ease in-out animation - Starts slow, fast in middle, ends slow
        public static let easeInOut = SwiftUI.Animation.easeInOut(duration: normal)

        private init() {}
    }

    // MARK: - Opacity Levels (subtle layering)

    /// Opacity constants for consistent transparency levels.
    ///
    /// ## Example
    /// ```swift
    /// Text("Disabled")
    ///     .opacity(DesignSystem.Opacity.disabled)
    /// ```
    public struct Opacity {
        /// Disabled state opacity (0.4)
        public static let disabled: Double = 0.4

        /// Muted content opacity (0.6)
        public static let muted: Double = 0.6

        /// Subtle content opacity (0.8)
        public static let subtle: Double = 0.8

        /// Full opacity (1.0)
        public static let full: Double = 1.0

        private init() {}
    }

    private init() {}
}

// MARK: - View Extensions for Design System

extension View {
    /// Apply a shadow style from the design system.
    ///
    /// ## Example
    /// ```swift
    /// CardView()
    ///     .shadowStyle(DesignSystem.Shadow.sm)
    /// ```
    public func shadowStyle(_ style: DesignSystem.ShadowStyle) -> some View {
        self.shadow(color: style.color, radius: style.radius, x: style.x, y: style.y)
    }

    /// Apply multiple shadow layers for enhanced depth.
    ///
    /// Creates a subtle, layered shadow effect by combining xs and sm shadows.
    ///
    /// ## Example
    /// ```swift
    /// CardView()
    ///     .layeredShadow()
    /// ```
    public func layeredShadow() -> some View {
        self
            .shadowStyle(DesignSystem.Shadow.xs)
            .shadowStyle(DesignSystem.Shadow.sm)
    }

    /// Apply press animation with natural spring curve.
    ///
    /// ## Example
    /// ```swift
    /// Button("Tap") {
    ///     // action
    /// }
    /// .pressAnimation(isPressed: isPressed)
    /// ```
    public func pressAnimation(isPressed: Bool) -> some View {
        self
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(DesignSystem.Animation.spring, value: isPressed)
    }

    /// Apply focus ring animation.
    ///
    /// ## Example
    /// ```swift
    /// TextField("Name", text: $name)
    ///     .focusRing(isFocused: isFocused, color: colors.primary)
    /// ```
    public func focusRing(isFocused: Bool, color: Color, cornerRadius: CGFloat = DesignSystem.CornerRadius.md) -> some View {
        self
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(color, lineWidth: 2)
                    .opacity(isFocused ? 1 : 0)
                    .scaleEffect(isFocused ? 1.0 : 0.95)
                    .animation(DesignSystem.Animation.spring, value: isFocused)
            )
    }

    /// Apply hover effect for iPad/Mac.
    ///
    /// ## Example
    /// ```swift
    /// CardView()
    ///     .cardHoverEffect()
    /// ```
    public func cardHoverEffect() -> some View {
        self
            .hoverEffect(.lift)
            .contentShape(Rectangle())
    }

    /// Apply dynamic shrinking animation (like tab bars during scroll).
    ///
    /// ## Example
    /// ```swift
    /// TabBar()
    ///     .dynamicShrink(isScrolling: isScrolling)
    /// ```
    public func dynamicShrink(isScrolling: Bool) -> some View {
        self
            .scaleEffect(isScrolling ? 0.9 : 1.0)
            .opacity(isScrolling ? 0.7 : 1.0)
            .animation(DesignSystem.Animation.springSmooth, value: isScrolling)
    }
}
