import SwiftUI

/// A reusable button configuration for SDK components.
///
/// ## Discussion
/// This configuration provides a standardized way to configure buttons across
/// the SDK, including title, style, colors, and callbacks.
///
/// ## Example
/// ```swift
/// let buttonConfig = ButtonConfiguration(
///     title: "Get Started",
///     style: .primary,
///     backgroundColor: .blue,
///     foregroundColor: .white,
///     action: {
///         print("Button tapped")
///     }
/// )
/// ```
public struct ButtonConfiguration: Sendable {
    /// The button title text.
    public let title: String
    
    /// The button style.
    public let style: ButtonStyle
    
    /// Background color of the button.
    public let backgroundColor: Color?
    
    /// Foreground (text) color of the button.
    public let foregroundColor: Color?
    
    /// Font weight for the button text.
    public let fontWeight: Font.Weight
    
    /// Font size for the button text.
    public let fontSize: CGFloat
    
    /// Corner radius for the button.
    public let cornerRadius: CGFloat
    
    /// Height of the button.
    public let height: CGFloat?
    
    /// Padding for the button content.
    public let padding: EdgeInsets
    
    /// Action to perform when button is tapped.
    public let action: (() -> Void)?
    
    /// Button style options.
    public enum ButtonStyle: Sendable {
        case primary
        case secondary
        case text
        case custom
    }
    
    public init(
        title: String,
        style: ButtonStyle = .primary,
        backgroundColor: Color? = nil,
        foregroundColor: Color? = nil,
        fontWeight: Font.Weight = .semibold,
        fontSize: CGFloat = 17,
        cornerRadius: CGFloat = 12,
        height: CGFloat? = 50,
        padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0),
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.style = style
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.fontWeight = fontWeight
        self.fontSize = fontSize
        self.cornerRadius = cornerRadius
        self.height = height
        self.padding = padding
        self.action = action
    }
    
    /// Default primary button configuration.
    public static func primary(
        title: String,
        backgroundColor: Color = .white,
        foregroundColor: Color = .black,
        action: (() -> Void)? = nil
    ) -> ButtonConfiguration {
        ButtonConfiguration(
            title: title,
            style: .primary,
            backgroundColor: backgroundColor,
            foregroundColor: foregroundColor,
            action: action
        )
    }
    
    /// Default secondary button configuration.
    public static func secondary(
        title: String,
        foregroundColor: Color = .white,
        action: (() -> Void)? = nil
    ) -> ButtonConfiguration {
        ButtonConfiguration(
            title: title,
            style: .secondary,
            foregroundColor: foregroundColor,
            height: nil,
            action: action
        )
    }
    
    /// Default text button configuration.
    public static func text(
        title: String,
        foregroundColor: Color = .white,
        action: (() -> Void)? = nil
    ) -> ButtonConfiguration {
        ButtonConfiguration(
            title: title,
            style: .text,
            foregroundColor: foregroundColor,
            cornerRadius: 0, height: nil,
            action: action
        )
    }
}


