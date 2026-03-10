import SwiftUI

/// Configuration for page indicator appearance and behavior.
///
/// ## Discussion
/// This configuration allows customization of page indicators in carousels,
/// including styling, custom views, or hiding them entirely.
///
/// ## Example
/// ```swift
/// // Default styled indicators
/// let indicatorConfig = PageIndicatorConfiguration(
///     activeColor: .blue,
///     inactiveColor: .gray,
///     size: 10
/// )
///
/// // Custom indicator view
/// let customConfig = PageIndicatorConfiguration(
///     customView: { currentPage, totalPages in
///         AnyView(Text("\(currentPage + 1) / \(totalPages)")
///             .foregroundColor(.white))
///     }
/// )
/// ```
public struct PageIndicatorConfiguration {
    /// Active indicator color (for current page).
    public let activeColor: Color?
    
    /// Inactive indicator color (for other pages).
    public let inactiveColor: Color?
    
    /// Size of each indicator dot.
    public let size: CGFloat?
    
    /// Spacing between indicator dots.
    public let spacing: CGFloat?
    
    /// Padding at the bottom of indicators.
    public let bottomPadding: CGFloat?
    
    /// Custom indicator view builder.
    /// Parameters: (currentPage: Int, totalPages: Int) -> AnyView
    public let customView: ((Int, Int) -> AnyView)?
    
    /// Whether to show indicators at all.
    public let isVisible: Bool
    
    /// Creates a page indicator configuration.
    ///
    /// - Parameters:
    ///   - activeColor: Color for the active/current page indicator. Defaults to white.
    ///   - inactiveColor: Color for inactive page indicators. Defaults to white with 0.3 opacity.
    ///   - size: Size of each indicator dot. Defaults to 8.
    ///   - spacing: Spacing between indicator dots. Defaults to 8.
    ///   - bottomPadding: Padding at the bottom of indicators. Defaults to 20.
    ///   - customView: Custom view builder to replace default indicators. If provided, other styling options are ignored.
    ///   - isVisible: Whether to show indicators. Defaults to true.
    public init(
        activeColor: Color? = .white,
        inactiveColor: Color? = Color.white.opacity(0.3),
        size: CGFloat? = 8,
        spacing: CGFloat? = 8,
        bottomPadding: CGFloat? = 20,
        customView: ((Int, Int) -> AnyView)? = nil,
        isVisible: Bool = true
    ) {
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.size = size
        self.spacing = spacing
        self.bottomPadding = bottomPadding
        self.customView = customView
        self.isVisible = isVisible
    }
    
    /// Default configuration with white indicators.
    public static let `default` = PageIndicatorConfiguration()
    
    /// Configuration that hides indicators.
    public static let hidden = PageIndicatorConfiguration(isVisible: false)
    
    /// Creates a configuration with custom colors.
    public static func styled(
        activeColor: Color = .white,
        inactiveColor: Color = Color.white.opacity(0.3),
        size: CGFloat = 8,
        spacing: CGFloat = 8
    ) -> PageIndicatorConfiguration {
        PageIndicatorConfiguration(
            activeColor: activeColor,
            inactiveColor: inactiveColor,
            size: size,
            spacing: spacing
        )
    }
    
    /// Creates a configuration with a custom view.
    public static func custom(
        _ viewBuilder: @escaping (Int, Int) -> AnyView
    ) -> PageIndicatorConfiguration {
        PageIndicatorConfiguration(customView: viewBuilder)
    }
}

