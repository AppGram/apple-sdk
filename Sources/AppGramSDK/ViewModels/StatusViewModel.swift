import Foundation
import SwiftUI

@MainActor
internal class StatusViewModel: ObservableObject {
    @Published private(set) var overview: StatusOverview?
    @Published private(set) var activeUpdates: [StatusUpdate] = []
    @Published private(set) var services: [StatusPageService] = []
    @Published private(set) var currentStatus: StatusType = .operational
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?

    private let service: StatusServiceProtocol
    private let projectId: String
    private let slug: String
    private var refreshTimer: Timer?
    private var notificationManager: NotificationManager?

    public var autoRefreshInterval: TimeInterval
    public var isAutoRefreshEnabled: Bool

    public init(
        service: StatusServiceProtocol,
        projectId: String,
        slug: String = "status",
        autoRefreshInterval: TimeInterval = 30,
        isAutoRefreshEnabled: Bool = true,
        notificationManager: NotificationManager? = nil
    ) {
        self.service = service
        self.projectId = projectId
        self.slug = slug
        self.autoRefreshInterval = autoRefreshInterval
        self.isAutoRefreshEnabled = isAutoRefreshEnabled
        self.notificationManager = notificationManager
    }

    deinit {
        refreshTimer?.invalidate()
    }

    public func loadOverview() async {
        isLoading = true
        error = nil

        do {
            let fetchedOverview = try await service.getStatusOverview(
                projectId: projectId,
                slug: slug
            )
            overview = fetchedOverview
            activeUpdates = fetchedOverview.activeUpdates
            services = fetchedOverview.services
            currentStatus = fetchedOverview.currentStatus
            isLoading = false

            if isAutoRefreshEnabled {
                startAutoRefresh()
            }
        } catch {
            self.error = error
            isLoading = false
            logError("Failed to load status overview: \(error.localizedDescription)")
        }
    }

    public func refresh() async {
        do {
            let fetchedOverview = try await service.getStatusOverview(
                projectId: projectId,
                slug: slug
            )

            // Check for new updates before updating state
            let previousUpdateIds = Set(activeUpdates.map { $0.id })
            let newUpdates = fetchedOverview.activeUpdates.filter { !previousUpdateIds.contains($0.id) }

            overview = fetchedOverview
            activeUpdates = fetchedOverview.activeUpdates
            services = fetchedOverview.services
            currentStatus = fetchedOverview.currentStatus

            // Notify about new updates
            if !newUpdates.isEmpty {
                notificationManager?.checkForNewStatusUpdates(newUpdates)
            }

            // Check for resolved updates
            let currentUpdateIds = Set(fetchedOverview.activeUpdates.map { $0.id })
            let resolvedUpdates = activeUpdates.filter { !currentUpdateIds.contains($0.id) }

            if !resolvedUpdates.isEmpty {
                notificationManager?.checkForResolvedStatusUpdates(resolvedUpdates)
            }
        } catch {
            logError("Failed to refresh status overview: \(error.localizedDescription)")
        }
    }

    private func startAutoRefresh() {
        stopAutoRefresh()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: autoRefreshInterval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.refresh()
            }
        }
    }

    private func stopAutoRefresh() {
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    public func setAutoRefresh(enabled: Bool) {
        isAutoRefreshEnabled = enabled
        if enabled {
            startAutoRefresh()
        } else {
            stopAutoRefresh()
        }
    }
}
