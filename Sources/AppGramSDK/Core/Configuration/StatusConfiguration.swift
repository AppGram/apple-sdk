import Foundation
import SwiftUI

/// Configuration options for customizing the status page view appearance and behavior.
///
/// ## Discussion
/// Use this configuration to customize how status information is displayed, including
/// auto-refresh settings, visual styling, and display preferences.
///
/// ## Example
/// ```swift
/// let config = StatusConfiguration(
///     title: "System Status",
///     autoRefreshInterval: 60,
///     enableAutoRefresh: true,
///     cardCornerRadius: 12,
///     accentColor: .green
/// )
/// ```
public struct StatusConfiguration: Sendable {
    /// The title displayed at the top of the status page.
    public var title: String
    
    /// The interval in seconds for automatic status updates.
    public var autoRefreshInterval: TimeInterval
    
    /// Whether to automatically refresh the status page.
    public var enableAutoRefresh: Bool
    
    /// The corner radius for status cards.
    public var cardCornerRadius: CGFloat
    
    /// The shadow radius for status cards.
    public var cardShadowRadius: CGFloat
    
    /// An optional accent color to apply to the status page.
    public var accentColor: Color?

    public init(
        title: String = "Service Status",
        autoRefreshInterval: TimeInterval = 30,
        enableAutoRefresh: Bool = true,
        cardCornerRadius: CGFloat = 12,
        cardShadowRadius: CGFloat = 2,
        accentColor: Color? = nil
    ) {
        self.title = title
        self.autoRefreshInterval = autoRefreshInterval
        self.enableAutoRefresh = enableAutoRefresh
        self.cardCornerRadius = cardCornerRadius
        self.cardShadowRadius = cardShadowRadius
        self.accentColor = accentColor
    }

    public static let `default` = StatusConfiguration()
}
