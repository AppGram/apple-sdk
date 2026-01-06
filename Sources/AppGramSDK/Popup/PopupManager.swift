import Foundation
import SwiftUI

/// Manager for controlling the automatic popup system.
///
/// The PopupManager orchestrates when and how popups are displayed, manages
/// user interactions, and coordinates with the PopupTracker to enforce
/// trigger conditions and snooze settings.
///
/// ## Example
/// ```swift
/// // Get the popup manager
/// let manager = try AppGramSDK.shared.getPopupManager()
///
/// // Manually trigger a popup
/// manager.showPopupManually()
///
/// // Stop the popup system
/// manager.stop()
/// ```
@MainActor
public final class PopupManager: ObservableObject {
    /// Whether the popup is currently being presented.
    @Published public private(set) var isPresented: Bool = false

    /// The current content to display in the popup.
    @Published public private(set) var currentContent: PopupContent?

    /// The popup configuration.
    public let configuration: PopupConfiguration

    private let tracker: PopupTracker
    private let projectId: String
    private var isRunning: Bool = false

    // Service references (optional because they might not be configured)
    private let surveyService: (any SurveyServiceProtocol)?
    private let feedbackService: (any FeedbackServiceProtocol)?

    /// Creates a new popup manager.
    ///
    /// - Parameters:
    ///   - configuration: The popup configuration.
    ///   - tracker: The tracker for managing popup state.
    ///   - projectId: The AppGram project ID.
    ///   - surveyService: Optional survey service reference.
    ///   - feedbackService: Optional feedback service reference.
    public init(
        configuration: PopupConfiguration,
        tracker: PopupTracker,
        projectId: String,
        surveyService: (any SurveyServiceProtocol)? = nil,
        feedbackService: (any FeedbackServiceProtocol)? = nil
    ) {
        self.configuration = configuration
        self.tracker = tracker
        self.projectId = projectId
        self.surveyService = surveyService
        self.feedbackService = feedbackService
    }

    // MARK: - Public API

    /// Starts the popup system.
    ///
    /// This enables automatic popup presentation based on the configured triggers.
    /// The popup system is automatically started when the SDK is configured with
    /// a popup configuration.
    public func start() {
        isRunning = true
        logDebug("PopupManager started")
    }

    /// Stops the popup system.
    ///
    /// This prevents automatic popups from appearing. Any currently shown popup
    /// will remain visible until dismissed by the user.
    public func stop() {
        isRunning = false
        logDebug("PopupManager stopped")
    }

    /// Manually triggers the popup to appear immediately.
    ///
    /// This bypasses all trigger conditions and shows the popup regardless
    /// of snooze settings or minimum intervals.
    public func showPopupManually() {
        currentContent = configuration.content
        isPresented = true

        Task {
            await tracker.recordShown()
        }

        logDebug("Popup shown manually")
    }

    /// Dismisses the currently shown popup.
    ///
    /// This hides the popup and records the dismissal in the tracker.
    public func dismiss() {
        isPresented = false
        currentContent = nil

        Task {
            await tracker.recordDismissed()
        }

        logDebug("Popup dismissed")
    }

    /// Snoozes the popup for the configured duration.
    ///
    /// This hides the popup and prevents it from appearing again until
    /// the snooze duration has elapsed.
    public func snooze() {
        isPresented = false
        currentContent = nil

        Task {
            await tracker.recordSnoozed()
        }

        logDebug("Popup snoozed for \(configuration.snoozeSettings.snoozeDuration) seconds")
    }

    // MARK: - Internal Methods

    /// Checks if the popup should be presented and shows it if conditions are met.
    ///
    /// This method is called automatically when the app launches or enters the foreground.
    /// It evaluates all trigger conditions and shows the popup if appropriate.
    public func checkAndPresentIfNeeded() async {
        guard isRunning else {
            logDebug("PopupManager not running, skipping check")
            return
        }

        // Record launch
        await tracker.recordLaunch()

        // Check if popup should be shown
        let shouldShow = await tracker.shouldShow(configuration: configuration)

        guard shouldShow else {
            logDebug("Popup conditions not met")
            return
        }

        // Show popup
        currentContent = configuration.content
        isPresented = true

        // Record that popup was shown
        await tracker.recordShown()

        // Log presentation with current metrics
        let launchCount = await tracker.getLaunchCount()
        let daysOfUsage = await tracker.getDaysOfUsage()
        logInfo("Popup presented (launch count: \(launchCount), days of usage: \(daysOfUsage))")
    }

    /// Records a user interaction with the popup.
    ///
    /// This is called when the user takes an action in the popup (e.g., taps a button).
    ///
    /// - Parameter type: The type of interaction.
    public func recordInteraction(_ type: InteractionType) {
        Task {
            await tracker.recordInteraction()
        }

        logDebug("Popup interaction recorded: \(type)")
    }
}

/// Types of user interactions with the popup.
public enum InteractionType {
    /// User tapped the main action button.
    case action

    /// User snoozed the popup.
    case snooze

    /// User dismissed the popup.
    case dismiss
}
