import Foundation
import SwiftUI

/// Configuration options for customizing a widget's appearance and behavior.
///
/// ## Discussion
/// WidgetConfiguration allows you to fully customize how a widget appears and behaves
/// in your app. You can customize colors, sizes, content, and the call-to-action button.
///
/// ## Example
/// ```swift
/// let config = WidgetConfiguration(
///     type: .feedback,
///     style: .card,
///     size: .medium,
///     ctaButton: CTAStyle(
///         title: "Submit Feedback",
///         backgroundColor: .blue,
///         foregroundColor: .white
///     )
/// )
/// ```
public struct AGWidgetConfiguration: Sendable {
    /// The type of widget content to display.
    public enum WidgetType: String, Sendable, Codable {
        /// Display feedback submission interface.
        case feedback
        /// Display roadmap items.
        case roadmap
        /// Display status page information.
        case status
        /// Display custom content provided by the user.
        case custom
    }
    
    /// Visual style of the widget.
    public enum WidgetStyle: String, Sendable, Codable {
        /// Card style with rounded corners and shadow.
        case card
        /// Minimal style with clean borders.
        case minimal
        /// Compact style for smaller spaces.
        case compact
        /// Banner style for horizontal layouts.
        case banner
    }
    
    /// Size preset for the widget.
    public enum WidgetSize: Sendable, Hashable {
        /// Small widget (ideal for sidebars).
        case small
        /// Medium widget (default, ideal for main content).
        case medium
        /// Large widget (ideal for full-width displays).
        case large
        /// Custom size defined by frame.
        case custom(CGSize)
        
        public func hash(into hasher: inout Hasher) {
            switch self {
            case .small:
                hasher.combine(0)
            case .medium:
                hasher.combine(1)
            case .large:
                hasher.combine(2)
            case .custom(let size):
                hasher.combine(3)
                hasher.combine(size.width)
                hasher.combine(size.height)
            }
        }
        
        public static func == (lhs: WidgetSize, rhs: WidgetSize) -> Bool {
            switch (lhs, rhs) {
            case (.small, .small), (.medium, .medium), (.large, .large):
                return true
            case (.custom(let lhsSize), .custom(let rhsSize)):
                return lhsSize == rhsSize
            default:
                return false
            }
        }
    }
    
    /// Configuration for the call-to-action button.
    public struct CTAStyle: Sendable {
        /// The title text for the CTA button.
        public let title: String
        
        /// Background color of the CTA button.
        public let backgroundColor: Color
        
        /// Foreground (text) color of the CTA button.
        public let foregroundColor: Color
        
        /// Font weight for the CTA button text.
        public let fontWeight: Font.Weight
        
        /// Corner radius for the CTA button.
        public let cornerRadius: CGFloat
        
        /// Padding for the CTA button.
        public let padding: EdgeInsets
        
        public init(
            title: String,
            backgroundColor: Color = .blue,
            foregroundColor: Color = .white,
            fontWeight: Font.Weight = .semibold,
            cornerRadius: CGFloat = 10,
            padding: EdgeInsets = EdgeInsets(top: 12, leading: 24, bottom: 12, trailing: 24)
        ) {
            self.title = title
            self.backgroundColor = backgroundColor
            self.foregroundColor = foregroundColor
            self.fontWeight = fontWeight
            self.cornerRadius = cornerRadius
            self.padding = padding
        }
        
        /// Default CTA style.
        public static let `default` = CTAStyle(
            title: "Get Started",
            backgroundColor: .blue,
            foregroundColor: .white
        )
    }
    
    /// The type of widget content.
    public let type: WidgetType
    
    /// The visual style of the widget.
    public let style: WidgetStyle
    
    /// The size of the widget.
    public let size: WidgetSize
    
    /// Configuration for the CTA button.
    public let ctaButton: CTAStyle?
    
    /// Custom title text for the widget.
    public let title: String?
    
    /// Custom subtitle/description text for the widget.
    public let subtitle: String?
    
    /// Custom background color for the widget.
    public let backgroundColor: Color?
    
    /// Custom border color for the widget.
    public let borderColor: Color?
    
    /// Border width for the widget.
    public let borderWidth: CGFloat
    
    /// Corner radius for the widget.
    public let cornerRadius: CGFloat
    
    /// Padding inside the widget.
    public let padding: EdgeInsets
    
    /// Custom content view builder (for custom widget type).
    public let customContent: (() -> AnyView)?
    
    /// Action to perform when CTA button is tapped.
    public let ctaAction: (() -> Void)?
    
    /// Additional parameters for widget-specific behavior.
    public let parameters: [String: String]
    
    public init(
        type: WidgetType,
        style: WidgetStyle = .card,
        size: WidgetSize = .medium,
        ctaButton: CTAStyle? = .default,
        title: String? = nil,
        subtitle: String? = nil,
        backgroundColor: Color? = nil,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1,
        cornerRadius: CGFloat = 12,
        padding: EdgeInsets = EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16),
        customContent: (() -> AnyView)? = nil,
        ctaAction: (() -> Void)? = nil,
        parameters: [String: String] = [:]
    ) {
        self.type = type
        self.style = style
        self.size = size
        self.ctaButton = ctaButton
        self.title = title
        self.subtitle = subtitle
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.cornerRadius = cornerRadius
        self.padding = padding
        self.customContent = customContent
        self.ctaAction = ctaAction
        self.parameters = parameters
    }
    
    /// Default widget configuration for feedback.
    public static func feedback(
        style: WidgetStyle = .card,
        size: WidgetSize = .medium,
        ctaButton: CTAStyle? = CTAStyle(title: "Submit Feedback"),
        ctaAction: (() -> Void)? = nil
    ) -> AGWidgetConfiguration {
        AGWidgetConfiguration(
            type: .feedback,
            style: style,
            size: size,
            ctaButton: ctaButton,
            title: "Share Your Feedback",
            subtitle: "Help us improve by sharing your thoughts",
            ctaAction: ctaAction
        )
    }
    
    /// Default widget configuration for roadmap.
    public static func roadmap(
        style: WidgetStyle = .card,
        size: WidgetSize = .medium,
        ctaButton: CTAStyle? = CTAStyle(title: "View Roadmap"),
        ctaAction: (() -> Void)? = nil
    ) -> AGWidgetConfiguration {
        AGWidgetConfiguration(
            type: .roadmap,
            style: style,
            size: size,
            ctaButton: ctaButton,
            title: "Product Roadmap",
            subtitle: "See what's coming next",
            ctaAction: ctaAction
        )
    }
    
    /// Default widget configuration for status.
    public static func status(
        style: WidgetStyle = .card,
        size: WidgetSize = .medium,
        ctaButton: CTAStyle? = CTAStyle(title: "View Status"),
        ctaAction: (() -> Void)? = nil,
        slug: String = "status"
    ) -> AGWidgetConfiguration {
        AGWidgetConfiguration(
            type: .status,
            style: style,
            size: size,
            ctaButton: ctaButton,
            title: "System Status",
            subtitle: "Check our service status",
            ctaAction: ctaAction,
            parameters: ["slug": slug]
        )
    }
    
    /// Default widget configuration for custom content.
    public static func custom(
        style: WidgetStyle = .card,
        size: WidgetSize = .medium,
        title: String? = nil,
        subtitle: String? = nil,
        ctaButton: CTAStyle? = nil,
        customContent: @escaping () -> AnyView,
        ctaAction: (() -> Void)? = nil
    ) -> AGWidgetConfiguration {
        AGWidgetConfiguration(
            type: .custom,
            style: style,
            size: size,
            ctaButton: ctaButton,
            title: title,
            subtitle: subtitle,
            customContent: customContent,
            ctaAction: ctaAction
        )
    }
}

