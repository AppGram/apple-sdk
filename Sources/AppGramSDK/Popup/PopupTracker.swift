import Foundation

/// Actor for tracking popup display state and evaluating trigger conditions.
///
/// The PopupTracker is responsible for:
/// - Recording app launches and usage metrics
/// - Persisting popup interaction data in UserDefaults
/// - Evaluating trigger conditions to determine when popups should appear
/// - Enforcing snooze periods and minimum intervals
///
/// All operations are thread-safe through the actor model.
public actor PopupTracker {
    private let storageKey = "com.appgram.sdk.popup"

    /// Internal data structure for persisting popup tracking information.
    private struct TrackerData: Codable {
        var launchCount: Int = 0
        var firstLaunchDate: Date?
        var lastShownDate: Date?
        var lastSnoozeDate: Date?
        var totalShownCount: Int = 0
        var dismissCount: Int = 0
        var interactionCount: Int = 0
    }

    public init() {}

    // MARK: - Recording Methods

    /// Records an app launch.
    ///
    /// This increments the launch counter and sets the first launch date if not already set.
    public func recordLaunch() {
        var data = loadData()
        data.launchCount += 1

        if data.firstLaunchDate == nil {
            data.firstLaunchDate = Date()
        }

        saveData(data)
    }

    /// Records that a popup was shown to the user.
    public func recordShown() {
        var data = loadData()
        data.lastShownDate = Date()
        data.totalShownCount += 1
        saveData(data)
    }

    /// Records that the user snoozed the popup.
    public func recordSnoozed() {
        var data = loadData()
        data.lastSnoozeDate = Date()
        saveData(data)
    }

    /// Records that the user dismissed the popup.
    public func recordDismissed() {
        var data = loadData()
        data.dismissCount += 1
        saveData(data)
    }

    /// Records that the user interacted with the popup (e.g., tapped a button).
    public func recordInteraction() {
        var data = loadData()
        data.interactionCount += 1
        saveData(data)
    }

    // MARK: - Evaluation Methods

    /// Determines whether the popup should be shown based on the configuration.
    ///
    /// This method evaluates all trigger conditions using OR logic - if ANY trigger
    /// condition is met, the popup can be shown (respecting snooze and minimum interval).
    ///
    /// - Parameter configuration: The popup configuration containing trigger conditions.
    /// - Returns: `true` if the popup should be shown, `false` otherwise.
    public func shouldShow(configuration: PopupConfiguration) -> Bool {
        // First check if we can show now (respects snooze and minimum interval)
        guard canShowNow(configuration: configuration) else {
            return false
        }

        let data = loadData()
        let conditions = configuration.triggerConditions

        // Check launch count trigger
        if let requiredLaunches = conditions.afterLaunches {
            if data.launchCount >= requiredLaunches {
                return true
            }
        }

        // Check days of usage trigger
        if let requiredDays = conditions.afterDaysOfUsage {
            if getDaysOfUsage() >= requiredDays {
                return true
            }
        }

        // Check repeat interval trigger
        if let interval = conditions.repeatInterval,
           let lastShown = data.lastShownDate {
            let nextShow = lastShown.addingTimeInterval(interval)
            if Date() >= nextShow {
                return true
            }
        }

        // If no triggers are configured or none are satisfied
        return false
    }

    /// Checks if the popup can be shown now, considering snooze and minimum interval.
    ///
    /// - Parameter configuration: The popup configuration.
    /// - Returns: `true` if the popup can be shown now, `false` if snoozed or too soon.
    public func canShowNow(configuration: PopupConfiguration) -> Bool {
        let data = loadData()

        // Check if snoozed
        if configuration.snoozeSettings.enabled,
           let lastSnooze = data.lastSnoozeDate {
            let snoozeEnd = lastSnooze.addingTimeInterval(configuration.snoozeSettings.snoozeDuration)
            if Date() < snoozeEnd {
                return false
            }
        }

        // Check minimum interval
        if let lastShown = data.lastShownDate {
            let nextAvailable = lastShown.addingTimeInterval(configuration.triggerConditions.minimumInterval)
            if Date() < nextAvailable {
                return false
            }
        }

        return true
    }

    /// Calculates the number of days since first app launch.
    ///
    /// - Returns: The number of days of usage, or 0 if no first launch date is recorded.
    public func getDaysOfUsage() -> Int {
        guard let firstLaunch = loadData().firstLaunchDate else {
            return 0
        }

        let calendar = Calendar.current
        let components = calendar.dateComponents(
            [.day],
            from: firstLaunch,
            to: Date()
        )

        return components.day ?? 0
    }

    // MARK: - Data Access

    /// Returns the current launch count.
    public func getLaunchCount() -> Int {
        return loadData().launchCount
    }

    /// Returns the date when the popup was last shown, if any.
    public func getLastShownDate() -> Date? {
        return loadData().lastShownDate
    }

    /// Returns the date when the popup was last snoozed, if any.
    public func getLastSnoozeDate() -> Date? {
        return loadData().lastSnoozeDate
    }

    /// Returns the total number of times the popup has been shown.
    public func getTotalShownCount() -> Int {
        return loadData().totalShownCount
    }

    /// Returns the number of times the popup was dismissed without interaction.
    public func getDismissCount() -> Int {
        return loadData().dismissCount
    }

    /// Returns the number of times the user interacted with the popup.
    public func getInteractionCount() -> Int {
        return loadData().interactionCount
    }

    /// Checks if the popup is currently in a snoozed state.
    ///
    /// - Parameter snoozeDuration: The snooze duration in seconds.
    /// - Returns: `true` if currently snoozed, `false` otherwise.
    public func isSnoozed(snoozeDuration: TimeInterval) -> Bool {
        guard let lastSnooze = loadData().lastSnoozeDate else {
            return false
        }

        let snoozeEnd = lastSnooze.addingTimeInterval(snoozeDuration)
        return Date() < snoozeEnd
    }

    // MARK: - Reset

    /// Resets all tracking data.
    ///
    /// This is useful for testing or when the user wants to reset popup preferences.
    public func reset() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    // MARK: - Private Methods

    private func loadData() -> TrackerData {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode(TrackerData.self, from: data) else {
            return TrackerData()
        }
        return decoded
    }

    private func saveData(_ data: TrackerData) {
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: storageKey)
        }
    }
}
