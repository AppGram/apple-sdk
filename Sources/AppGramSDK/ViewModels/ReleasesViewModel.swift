import Foundation
import SwiftUI

@MainActor
internal class ReleasesViewModel: ObservableObject {
    @Published private(set) var releases: [Release] = []
    @Published public var selectedRelease: Release?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let service: ReleasesServiceProtocol
    private let orgSlug: String
    private let projectSlug: String
    private var notificationManager: NotificationManager?

    public init(
        service: ReleasesServiceProtocol,
        orgSlug: String,
        projectSlug: String,
        notificationManager: NotificationManager? = nil
    ) {
        self.service = service
        self.orgSlug = orgSlug
        self.projectSlug = projectSlug
        self.notificationManager = notificationManager
    }

    public func loadReleases(limit: Int = 50) async {
        isLoading = true
        error = nil

        do {
            let previousReleaseIds = Set(releases.map { $0.id })
            let fetchedReleases = try await service.getReleases(
                orgSlug: orgSlug,
                projectSlug: projectSlug,
                limit: limit
            )

            // Check for new releases
            let newReleases = fetchedReleases.filter { !previousReleaseIds.contains($0.id) }

            releases = fetchedReleases
            isLoading = false

            // Notify about new releases
            if !newReleases.isEmpty && !previousReleaseIds.isEmpty {
                notificationManager?.checkForNewReleases(newReleases)
            }
        } catch {
            self.error = error
            isLoading = false
            logError("Failed to load releases: \(error.localizedDescription)")
        }
    }

    public func selectRelease(slug: String) async {
        do {
            var release = try await service.getRelease(
                orgSlug: orgSlug,
                projectSlug: projectSlug,
                releaseSlug: slug
            )

            // Fetch features if release doesn't already have them
            // Note: Features might already be included in the public release response
            if release.features == nil {
                do {
                    let features = try await service.getReleaseFeatures(releaseId: release.id)
                    release.features = features
                } catch {
                    // If fetching features fails (e.g., 401 Unauthorized for public releases),
                    // log the error but continue without features rather than failing the entire operation
                    if let appGramError = error as? AppGramError,
                       case .unauthorized = appGramError {
                        logDebug("Features endpoint requires authentication. Showing release without features.")
                    } else {
                        logError("Failed to load release features: \(error.localizedDescription)")
                    }
                    // Continue with release.features = nil
                }
            }

            selectedRelease = release
        } catch {
            logError("Failed to load release: \(error.localizedDescription)")
        }
    }

    public func clearSelection() {
        selectedRelease = nil
    }
}
