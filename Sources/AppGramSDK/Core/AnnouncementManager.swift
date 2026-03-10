import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// Configuration for announcement display behavior.
///
/// ## Discussion
/// This configuration controls when and how announcements are shown to users.
public struct AnnouncementConfiguration {
    /// The organization slug to fetch releases from.
    public let orgSlug: String

    /// The project slug to fetch releases from.
    public let projectSlug: String

    /// Whether to automatically show announcements on app launch.
    public let showOnLaunch: Bool

    /// Minimum hours between automatic announcement displays.
    public let minimumHoursBetweenShows: Int

    /// Maximum number of announcements to show at once.
    public let maxAnnouncementsToShow: Int
    
    /// Configuration for the announcement card appearance and buttons.
    public let cardConfiguration: AnnouncementCardConfiguration

    /// Creates an announcement configuration.
    ///
    /// - Parameters:
    ///   - orgSlug: The organization slug.
    ///   - projectSlug: The project slug.
    ///   - showOnLaunch: Whether to show on app launch. Defaults to `true`.
    ///   - minimumHoursBetweenShows: Minimum hours between shows. Defaults to 24.
    ///   - maxAnnouncementsToShow: Maximum announcements to show. Defaults to 3.
    ///   - cardConfiguration: Configuration for card appearance and buttons. Defaults to `.default`.
    public init(
        orgSlug: String,
        projectSlug: String,
        showOnLaunch: Bool = true,
        minimumHoursBetweenShows: Int = 24,
        maxAnnouncementsToShow: Int = 3,
        cardConfiguration: AnnouncementCardConfiguration = .default
    ) {
        self.orgSlug = orgSlug
        self.projectSlug = projectSlug
        self.showOnLaunch = showOnLaunch
        self.minimumHoursBetweenShows = minimumHoursBetweenShows
        self.maxAnnouncementsToShow = maxAnnouncementsToShow
        self.cardConfiguration = cardConfiguration
    }
}

/// Manages the display and lifecycle of announcements.
///
/// ## Discussion
/// The announcement manager handles fetching features from releases and creating
/// one announcement per feature. It tracks seen features and presents the
/// announcement modal at appropriate times.
@MainActor
public final class AnnouncementManager: ObservableObject {
    @Published public private(set) var isShowingAnnouncements: Bool = false

    private let configuration: AnnouncementConfiguration
    private let releasesService: ReleasesServiceProtocol
    private var viewModel: AnnouncementViewModel?
    private var isStarted: Bool = false
    #if canImport(UIKit)
    private weak var hostingController: UIViewController?
    #endif

    /// Callback invoked when user takes action on an announcement.
    public var onAnnouncementAction: ((Announcement) -> Void)?

    /// Initializes the announcement manager.
    ///
    /// - Parameters:
    ///   - configuration: The configuration for announcement display.
    ///   - releasesService: The service to fetch releases from.
    public init(
        configuration: AnnouncementConfiguration,
        releasesService: ReleasesServiceProtocol
    ) {
        self.configuration = configuration
        self.releasesService = releasesService

        self.viewModel = AnnouncementViewModel(
            releasesService: releasesService,
            orgSlug: configuration.orgSlug,
            projectSlug: configuration.projectSlug,
            maxAnnouncementsToShow: configuration.maxAnnouncementsToShow
        )
    }

    /// Starts the announcement manager.
    ///
    /// This should be called during SDK initialization.
    public func start() {
        guard !isStarted else {
            logWarning("AnnouncementManager already started")
            return
        }

        isStarted = true
        logInfo("AnnouncementManager started")

        // Prefetch announcements in background (including seen ones for instant manual display)
        Task {
            await checkAndFetchAnnouncements()
            // Also prefetch all announcements (including seen) for instant manual display
            await prefetchAllAnnouncements()
        }
    }

    /// Checks for new announcements and fetches them if needed.
    public func checkAndFetchAnnouncements() async {
        guard let viewModel = viewModel else {
            return
        }

        await viewModel.fetchAnnouncements(includeSeen: false)
    }
    
    /// Prefetches all announcements (including seen ones) for instant manual display.
    private func prefetchAllAnnouncements() async {
        guard let viewModel = viewModel else {
            return
        }
        
        // Prefetch all announcements including seen ones so manual triggers are instant
        await viewModel.fetchAnnouncements(includeSeen: true)
        logDebug("Prefetched all announcements for instant display")
    }

    /// Checks if announcements should be shown and displays them if appropriate.
    ///
    /// This is called automatically on app launch if configured to do so.
    public func checkAndPresentIfNeeded() async {
        guard configuration.showOnLaunch else {
            logDebug("Announcements not configured for automatic launch display")
            return
        }

        guard let viewModel = viewModel else {
            return
        }

        // Check if we should show announcements
        if viewModel.shouldShowAnnouncementsAutomatically(
            minimumHoursSinceLastCheck: configuration.minimumHoursBetweenShows
        ) {
            await presentAnnouncements()
        }
    }

    /// Manually presents announcements.
    ///
    /// Use this method when the user explicitly requests to see announcements
    /// (e.g., from a "What's New" button).
    ///
    /// When manually triggered, this will show announcements even if they've been seen before.
    public func presentAnnouncements() async {
        guard let viewModel = viewModel else {
            return
        }

        // Use cached announcements if available for instant display
        if viewModel.isAllAnnouncementsCached && !viewModel.allAnnouncementsCache.isEmpty {
            logDebug("Using prefetched announcements for instant display")
            viewModel.setAnnouncements(viewModel.allAnnouncementsCache)
        } else {
            // Fetch if not cached (should rarely happen if prefetch worked)
            logDebug("No prefetched announcements, fetching now...")
            await viewModel.fetchAnnouncements(includeSeen: true)
        }

        // Show if we have announcements
        if !viewModel.announcements.isEmpty {
            showAnnouncementModal()
        } else {
            logInfo("No announcements to display")
        }
    }

    /// Clears the seen announcement history.
    ///
    /// This allows all announcements to be shown again.
    public func clearSeenHistory() {
        viewModel?.clearSeenHistory()
        logInfo("Cleared announcement seen history")
    }

    // MARK: - Private Methods

    #if canImport(UIKit)
    /// Finds the topmost view controller in the view hierarchy.
    private func topMostViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }),
              let rootViewController = window.rootViewController else {
            return nil
        }
        
        var topController = rootViewController
        while let presented = topController.presentedViewController {
            topController = presented
        }
        return topController
    }
    #endif

    private func showAnnouncementModal() {
        guard let viewModel = viewModel else {
            return
        }

        #if canImport(UIKit)
        guard let topViewController = topMostViewController() else {
            logError("Failed to find topmost view controller for announcement display")
            return
        }

        let modalView = AnnouncementModalView(
            announcements: viewModel.announcements,
            cardConfiguration: configuration.cardConfiguration,
            onDismiss: { [weak self] in
                self?.dismissAnnouncementModal()
            },
            onAction: { [weak self] announcement in
                self?.handleAnnouncementAction(announcement)
            }
        )

        let hostingController = UIHostingController(rootView: modalView)
        hostingController.view.backgroundColor = .clear
        hostingController.modalPresentationStyle = .overFullScreen
        hostingController.modalTransitionStyle = .crossDissolve
        
        // Store reference for dismissal
        self.hostingController = hostingController

        topViewController.present(hostingController, animated: true) {
            self.isShowingAnnouncements = true
        }

        logInfo("Showing \(viewModel.announcements.count) announcements")
        #endif
    }

    private func dismissAnnouncementModal() {
        // Mark current announcements as seen
        viewModel?.markCurrentAnnouncementsSeen()

        #if canImport(UIKit)
        // Use stored reference to dismiss
        if let hostingController = hostingController {
            hostingController.dismiss(animated: true) { [weak self] in
                self?.isShowingAnnouncements = false
                self?.hostingController = nil
                logInfo("Announcement modal dismissed successfully")
            }
        } else {
            // Fallback: try to find and dismiss from topmost
            if let topVC = topMostViewController(),
               let presentingVC = topVC.presentingViewController {
                presentingVC.dismiss(animated: true) { [weak self] in
                    self?.isShowingAnnouncements = false
                }
            } else {
                self.isShowingAnnouncements = false
                logWarning("Could not find announcement modal to dismiss")
            }
        }
        #endif
    }

    private func handleAnnouncementAction(_ announcement: Announcement) {
        logInfo("User took action on announcement: \(announcement.id)")
        onAnnouncementAction?(announcement)
    }
}
