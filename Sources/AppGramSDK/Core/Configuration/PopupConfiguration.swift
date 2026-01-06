import Foundation
import SwiftUI

/// Configuration options for customizing the automatic popup system behavior and appearance.
///
/// ## Discussion
/// Use this configuration to control when and how automatic popups appear, including
/// trigger conditions, content types, presentation styles, and user interaction options.
///
/// ## Example
/// ```swift
/// let config = PopupConfiguration(
///     triggerConditions: .init(
///         afterLaunches: 5,
///         minimumInterval: 86400 * 14
///     ),
///     content: .survey(slug: "nps-survey", style: .typeform),
///     presentationStyle: .sheet,
///     snoozeSettings: .init(
///         enabled: true,
///         snoozeDuration: 86400 * 7,
///         buttonTitle: "Ask me later"
///     )
/// )
///
/// AppGramSDK.shared.configure(
///     projectId: "your-project-id",
///     popupConfiguration: config
/// )
/// ```
public struct PopupConfiguration: Sendable {
    /// The trigger conditions that determine when the popup should appear.
    public var triggerConditions: TriggerConditions

    /// The content to display in the popup.
    public var content: PopupContent

    /// The presentation style for the popup.
    public var presentationStyle: PresentationStyle

    /// Display settings for customizing the popup appearance.
    public var displaySettings: DisplaySettings

    /// Settings for the snooze functionality.
    public var snoozeSettings: SnoozeSettings

    public init(
        triggerConditions: TriggerConditions = .default,
        content: PopupContent = .feedback,
        presentationStyle: PresentationStyle = .bottomBanner,
        displaySettings: DisplaySettings = .default,
        snoozeSettings: SnoozeSettings = .default
    ) {
        self.triggerConditions = triggerConditions
        self.content = content
        self.presentationStyle = presentationStyle
        self.displaySettings = displaySettings
        self.snoozeSettings = snoozeSettings
    }

    /// Default popup configuration with sensible defaults.
    ///
    /// Triggers after 3 app launches with a 7-day minimum interval between shows.
    /// Displays a feedback prompt in a bottom banner with snooze enabled.
    public static let `default` = PopupConfiguration()
}

/// Trigger conditions that determine when the popup should appear.
///
/// Multiple conditions can be set, and they use OR logic - if ANY condition is met,
/// the popup can appear (respecting minimum interval and snooze settings).
public struct TriggerConditions: Sendable {
    /// Show popup after this many app launches. Set to `nil` to disable.
    public var afterLaunches: Int?

    /// Show popup after this many days of usage. Set to `nil` to disable.
    public var afterDaysOfUsage: Int?

    /// Show popup repeatedly at this interval (in seconds). Set to `nil` to disable.
    public var repeatInterval: TimeInterval?

    /// Minimum interval (in seconds) between popup displays.
    ///
    /// This prevents the popup from appearing too frequently, regardless of which
    /// trigger conditions are met.
    public var minimumInterval: TimeInterval

    public init(
        afterLaunches: Int? = 3,
        afterDaysOfUsage: Int? = nil,
        repeatInterval: TimeInterval? = nil,
        minimumInterval: TimeInterval = 86400 * 7 // 7 days
    ) {
        self.afterLaunches = afterLaunches
        self.afterDaysOfUsage = afterDaysOfUsage
        self.repeatInterval = repeatInterval
        self.minimumInterval = minimumInterval
    }

    /// Default trigger conditions.
    ///
    /// Shows popup after 3 app launches with a 7-day minimum interval.
    public static let `default` = TriggerConditions()
}

/// The type of content to display in the popup.
public enum PopupContent: Sendable {
    /// Display a survey identified by its slug.
    ///
    /// - Parameters:
    ///   - slug: The unique identifier of the survey.
    ///   - style: The visual style of the survey (normal or typeform).
    case survey(slug: String, style: SurveyStyle = .normal)

    /// Display a feedback prompt that opens the feedback view.
    case feedback

    /// Display custom content using a provided view builder.
    ///
    /// - Parameter viewBuilder: A closure that returns the custom view to display.
    case customView(@Sendable () -> AnyView)
}

/// The presentation style for the popup.
public enum PresentationStyle: String, Sendable {
    /// Display as a bottom banner that slides up from the bottom of the screen.
    case bottomBanner

    /// Display as a sheet modal that slides up from the bottom.
    case sheet
}

/// Display settings for customizing the popup appearance.
public struct DisplaySettings: Sendable {
    /// The duration of the animation when showing/hiding the popup.
    public var animationDuration: TimeInterval

    /// The corner radius for the popup card.
    public var cornerRadius: CGFloat

    /// The shadow radius for the popup card.
    public var shadowRadius: CGFloat

    /// Optional maximum width for the popup. Set to `nil` for no constraint.
    public var maxWidth: CGFloat?

    public init(
        animationDuration: TimeInterval = 0.4,
        cornerRadius: CGFloat = 16,
        shadowRadius: CGFloat = 8,
        maxWidth: CGFloat? = nil
    ) {
        self.animationDuration = animationDuration
        self.cornerRadius = cornerRadius
        self.shadowRadius = shadowRadius
        self.maxWidth = maxWidth
    }

    /// Default display settings.
    public static let `default` = DisplaySettings()
}

/// Settings for the popup snooze functionality.
public struct SnoozeSettings: Sendable {
    /// Whether the snooze button is enabled.
    public var enabled: Bool

    /// The duration (in seconds) to snooze the popup when the snooze button is tapped.
    public var snoozeDuration: TimeInterval

    /// The title text for the snooze button.
    public var buttonTitle: String

    public init(
        enabled: Bool = true,
        snoozeDuration: TimeInterval = 86400 * 7, // 7 days
        buttonTitle: String = "Ask me later"
    ) {
        self.enabled = enabled
        self.snoozeDuration = snoozeDuration
        self.buttonTitle = buttonTitle
    }

    /// Default snooze settings.
    ///
    /// Snooze is enabled for 7 days with "Ask me later" button title.
    public static let `default` = SnoozeSettings()
}
