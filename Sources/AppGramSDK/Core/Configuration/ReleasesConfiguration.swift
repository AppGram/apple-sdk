import Foundation
import SwiftUI

/// Configuration options for customizing the releases view appearance and behavior.
///
/// ## Discussion
/// Use this configuration to customize how release notes are displayed, including
/// visual styling, layout options, and display preferences.
///
/// ## Example
/// ```swift
/// let config = ReleasesConfiguration(
///     title: "What's New",
///     showVersionBadge: true,
///     cardCornerRadius: 16,
///     accentColor: .blue
/// )
/// ```
public struct ReleasesConfiguration: Sendable {
    /// The title displayed at the top of the releases view.
    public var title: String
    
    /// Whether to show version badges on release cards.
    public var showVersionBadge: Bool
    
    /// The corner radius for release cards.
    public var cardCornerRadius: CGFloat
    
    /// The corner radius for release images.
    public var imageCornerRadius: CGFloat
    
    /// An optional accent color to apply to the releases view.
    public var accentColor: Color?

    public init(
        title: String = "Release Notes",
        showVersionBadge: Bool = true,
        cardCornerRadius: CGFloat = 12,
        imageCornerRadius: CGFloat = 8,
        accentColor: Color? = nil
    ) {
        self.title = title
        self.showVersionBadge = showVersionBadge
        self.cardCornerRadius = cardCornerRadius
        self.imageCornerRadius = imageCornerRadius
        self.accentColor = accentColor
    }

    public static let `default` = ReleasesConfiguration()
}
