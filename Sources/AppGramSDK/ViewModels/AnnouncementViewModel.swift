import Foundation
import SwiftUI

/// View model for managing announcements display and tracking.
///
/// ## Discussion
/// This view model handles fetching features from releases and creating
/// one announcement per feature. It tracks which features have been seen
/// and determines when to display new feature announcements to users.
@MainActor
public final class AnnouncementViewModel: ObservableObject {
    @Published public private(set) var announcements: [Announcement] = [] {
        didSet {
            // Allow internal access for caching
        }
    }
    
    /// Sets announcements (internal use for caching)
    internal func setAnnouncements(_ announcements: [Announcement]) {
        self.announcements = announcements
    }
    @Published public private(set) var isLoading: Bool = false
    @Published public private(set) var error: AppGramError?
    @Published public var shouldShowAnnouncements: Bool = false
    
    // Cache for all announcements (including seen) for instant manual display
    var allAnnouncementsCache: [Announcement] = []
    var isAllAnnouncementsCached: Bool = false

    private let releasesService: ReleasesServiceProtocol
    private let orgSlug: String
    private let projectSlug: String
    private let userDefaults: UserDefaults
    private let maxAnnouncementsToShow: Int

    private static let seenAnnouncementsKey = "com.appgram.seenAnnouncements"
    private static let lastCheckDateKey = "com.appgram.lastAnnouncementCheckDate"

    /// Initializes the announcement view model.
    ///
    /// - Parameters:
    ///   - releasesService: The service to fetch releases and features from.
    ///   - orgSlug: The organization slug.
    ///   - projectSlug: The project slug.
    ///   - maxAnnouncementsToShow: Maximum number of feature announcements to display at once. Defaults to 3.
    ///   - userDefaults: UserDefaults instance for persistence. Defaults to `.standard`.
    public init(
        releasesService: ReleasesServiceProtocol,
        orgSlug: String,
        projectSlug: String,
        maxAnnouncementsToShow: Int = 3,
        userDefaults: UserDefaults = .standard
    ) {
        self.releasesService = releasesService
        self.orgSlug = orgSlug
        self.projectSlug = projectSlug
        self.maxAnnouncementsToShow = maxAnnouncementsToShow
        self.userDefaults = userDefaults
    }

    /// Fetches new announcements from releases.
    ///
    /// This method retrieves the latest releases, extracts features from them,
    /// and creates one announcement per feature. It filters out features that
    /// have already been seen by the user.
    ///
    /// - Parameter includeSeen: If `true`, includes announcements that have already been seen. Defaults to `false`.
    public func fetchAnnouncements(includeSeen: Bool = false) async {
        isLoading = true
        error = nil

        do {
            logInfo("Fetching announcements for \(orgSlug)/\(projectSlug)")

            // Fetch recent releases (fetch more to get enough features)
            let releases = try await releasesService.getReleases(
                orgSlug: orgSlug,
                projectSlug: projectSlug,
                limit: maxAnnouncementsToShow * 3 // Fetch more releases to get enough features
            )

            logDebug("Fetched \(releases.count) releases")

            // Extract all features from all releases and create one announcement per feature
            var fetchedAnnouncements: [Announcement] = []
            let seenFeatureIds = includeSeen ? [] : getSeenAnnouncementIds() // Track seen features by feature ID

            for release in releases {
                // Fetch features for this release if not already included
                var releaseWithFeatures = release
                if release.features == nil || release.features?.isEmpty == true {
                    do {
                        let features = try await releasesService.getReleaseFeatures(releaseId: release.id)
                        releaseWithFeatures.features = features
                    } catch {
                        logWarning("Failed to fetch features for release \(release.id): \(error)")
                        continue // Skip this release if we can't get features
                    }
                }

                // Create one announcement per feature
                guard let features = releaseWithFeatures.features else {
                    continue
                }

                for feature in features {
                    // Skip if this feature has already been seen (unless includeSeen is true)
                    if !includeSeen && seenFeatureIds.contains(feature.id) {
                        continue
                    }

                    // Create an announcement for this single feature
                    let announcementFeature = AnnouncementFeature(
                        id: feature.id,
                        title: feature.title,
                        description: feature.description,
                        imageUrl: feature.imageUrl
                    )

                    let announcement = Announcement(
                        id: feature.id, // Use feature ID as announcement ID
                        title: feature.title,
                        subtitle: feature.description,
                        features: [announcementFeature], // Single feature per announcement
                        version: release.version,
                        imageUrl: feature.imageUrl ?? release.coverImageUrl,
                        privacyNote: nil,
                        learnMoreUrl: nil,
                        createdAt: feature.createdAt
                    )

                    fetchedAnnouncements.append(announcement)

                    // Stop once we have enough announcements
                    if fetchedAnnouncements.count >= maxAnnouncementsToShow {
                        break
                    }
                }

                // Stop if we have enough announcements
                if fetchedAnnouncements.count >= maxAnnouncementsToShow {
                    break
                }
            }

            announcements = fetchedAnnouncements
            shouldShowAnnouncements = !fetchedAnnouncements.isEmpty
            
            // If fetching all announcements (including seen), cache them for instant manual display
            if includeSeen {
                allAnnouncementsCache = fetchedAnnouncements
                isAllAnnouncementsCached = true
                logDebug("Cached \(fetchedAnnouncements.count) announcements (including seen) for instant display")
            }

            // Update last check date
            userDefaults.set(Date(), forKey: Self.lastCheckDateKey)

            logInfo("Found \(announcements.count) new feature announcements")
        } catch {
            logError("Failed to fetch announcements: \(error)")
            self.error = error as? AppGramError ?? .forbidden
        }

        isLoading = false
    }

    /// Marks feature announcements as seen.
    ///
    /// - Parameter announcementIds: The IDs of feature announcements (feature IDs) to mark as seen.
    public func markAnnouncementsSeen(_ announcementIds: [String]) {
        var seenIds = getSeenAnnouncementIds()
        seenIds.append(contentsOf: announcementIds)

        // Remove duplicates
        seenIds = Array(Set(seenIds))

        // Keep only the last 100 seen announcements to avoid growing indefinitely
        if seenIds.count > 100 {
            seenIds = Array(seenIds.suffix(100))
        }

        userDefaults.set(seenIds, forKey: Self.seenAnnouncementsKey)
        logDebug("Marked \(announcementIds.count) announcements as seen")
    }

    /// Marks all current feature announcements as seen.
    public func markCurrentAnnouncementsSeen() {
        let ids = announcements.map { $0.id }
        markAnnouncementsSeen(ids)
    }

    /// Checks if announcements should be shown automatically.
    ///
    /// This considers whether there are unseen announcements and
    /// whether enough time has passed since the last check.
    ///
    /// - Parameter minimumHoursSinceLastCheck: Minimum hours that must pass before showing again.
    /// - Returns: `true` if announcements should be shown, `false` otherwise.
    public func shouldShowAnnouncementsAutomatically(minimumHoursSinceLastCheck: Int = 24) -> Bool {
        guard !announcements.isEmpty else {
            return false
        }

        // Check if enough time has passed since last check
        if let lastCheck = userDefaults.object(forKey: Self.lastCheckDateKey) as? Date {
            let hoursSinceLastCheck = Date().timeIntervalSince(lastCheck) / 3600
            if hoursSinceLastCheck < Double(minimumHoursSinceLastCheck) {
                logDebug("Not showing announcements: only \(hoursSinceLastCheck) hours since last check")
                return false
            }
        }

        return true
    }

    /// Clears all seen announcement history.
    ///
    /// This is useful for testing or if the user wants to see announcements again.
    public func clearSeenHistory() {
        userDefaults.removeObject(forKey: Self.seenAnnouncementsKey)
        userDefaults.removeObject(forKey: Self.lastCheckDateKey)
        logInfo("Cleared announcement history")
    }

    // MARK: - Private Methods

    private func getSeenAnnouncementIds() -> [String] {
        return userDefaults.stringArray(forKey: Self.seenAnnouncementsKey) ?? []
    }
}
