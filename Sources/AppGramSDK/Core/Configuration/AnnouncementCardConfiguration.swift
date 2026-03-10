import SwiftUI

/// Configuration for announcement card appearance and behavior.
///
/// ## Discussion
/// This configuration allows customization of the announcement card's
/// background, buttons, and overall styling.
///
/// ## Example
/// ```swift
/// // Basic configuration
/// let cardConfig = AnnouncementCardConfiguration(
///     backgroundColor: Color(white: 0.2),
///     primaryButton: .primary(title: "Try it"),
///     secondaryButton: .secondary(title: "Not now"),
///     cornerRadius: 20,
///     modalPadding: 20
/// )
///
/// // With custom page indicators
/// let customIndicatorConfig = AnnouncementCardConfiguration(
///     pageIndicatorConfiguration: .styled(
///         activeColor: .blue,
///         inactiveColor: .gray,
///         size: 10,
///         spacing: 12
///     )
/// )
///
/// // With custom indicator view
/// let customViewConfig = AnnouncementCardConfiguration(
///     pageIndicatorConfiguration: .custom { currentPage, totalPages in
///         AnyView(Text("\(currentPage + 1) / \(totalPages)")
///             .foregroundColor(.white))
///     }
/// )
/// ```
public struct AnnouncementCardConfiguration {
    /// Visual presentation style for the announcement content.
    public enum PresentationStyle {
        /// Renders content inside a card with background, border, and shadow.
        case card
        /// Renders content flush inside a container like a bottom sheet.
        case sheet
    }

    /// Background color for the announcement card.
    public let backgroundColor: Color?
    
    /// Primary button configuration (optional).
    public let primaryButton: ButtonConfiguration?
    
    /// Secondary button configuration (optional).
    public let secondaryButton: ButtonConfiguration?
    
    /// Title text color.
    public let titleColor: Color?
    
    /// Description text color.
    public let descriptionColor: Color?
    
    /// Title font size.
    public let titleFontSize: CGFloat
    
    /// Description font size.
    public let descriptionFontSize: CGFloat
    
    /// Corner radius for the announcement card.
    public let cornerRadius: CGFloat
    
    /// Padding around the card within the modal.
    public let modalPadding: CGFloat

    /// Presentation style for the announcement content.
    public let presentationStyle: PresentationStyle
    
    /// Configuration for page indicators when multiple announcements are shown.
    public let pageIndicatorConfiguration: PageIndicatorConfiguration
    
    /// Creates an announcement card configuration.
    ///
    /// - Parameters:
    ///   - backgroundColor: Background color for the card. Defaults to nil to follow the theme.
    ///   - primaryButton: Primary button configuration. Defaults to "Try it" button.
    ///   - secondaryButton: Secondary button configuration. Defaults to "Not now" button.
    ///   - titleColor: Title text color. Defaults to nil to follow the theme.
    ///   - descriptionColor: Description text color. Defaults to nil to follow the theme.
    ///   - titleFontSize: Title font size. Defaults to 30.
    ///   - descriptionFontSize: Description font size. Defaults to 16.
    ///   - cornerRadius: Corner radius for the card. Defaults to 24.
    ///   - modalPadding: Padding around the card within the modal. Defaults to 20.
    ///   - pageIndicatorConfiguration: Configuration for page indicators. Defaults to `.default`.
    ///   - presentationStyle: Presentation style for the content. Defaults to `.card`.
    public init(
        backgroundColor: Color? = nil,
        primaryButton: ButtonConfiguration? = ButtonConfiguration(title: "Try it"),
        secondaryButton: ButtonConfiguration? = ButtonConfiguration(title: "Not now", style: .secondary, height: nil),
        titleColor: Color? = nil,
        descriptionColor: Color? = nil,
        titleFontSize: CGFloat = 30,
        descriptionFontSize: CGFloat = 16,
        cornerRadius: CGFloat = 24,
        modalPadding: CGFloat = 20,
        pageIndicatorConfiguration: PageIndicatorConfiguration = .default,
        presentationStyle: PresentationStyle = .card
    ) {
        self.backgroundColor = backgroundColor
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
        self.titleColor = titleColor
        self.descriptionColor = descriptionColor
        self.titleFontSize = titleFontSize
        self.descriptionFontSize = descriptionFontSize
        self.cornerRadius = cornerRadius
        self.modalPadding = modalPadding
        self.pageIndicatorConfiguration = pageIndicatorConfiguration
        self.presentationStyle = presentationStyle
    }
    
    /// Default configuration matching ChatGPT agent mode style.
    public static let `default` = AnnouncementCardConfiguration()
    
    /// Configuration with no buttons.
    public static let noButtons = AnnouncementCardConfiguration(
        primaryButton: nil,
        secondaryButton: nil
    )

    /// Configuration for bottom-sheet style presentation (no card chrome).
    public static let sheet = AnnouncementCardConfiguration(presentationStyle: .sheet)
}
