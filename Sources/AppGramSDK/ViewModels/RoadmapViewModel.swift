import Foundation
import SwiftUI

@MainActor
@Observable
internal final class RoadmapViewModel {
    public private(set) var items: [RoadmapItem] = []
    public private(set) var columns: [RoadmapColumn] = []
    public private(set) var isLoading = false
    public private(set) var error: AppGramError?

    public var selectedLayout: RoadmapLayout = .kanban
    public var selectedCategory: Category?

    private let roadmapService: RoadmapServiceProtocol

    public init(roadmapService: RoadmapServiceProtocol) {
        self.roadmapService = roadmapService
    }

    public func loadRoadmap() async {
        logDebug("RoadmapViewModel: Loading roadmap")
        isLoading = true
        error = nil

        do {
            items = try await roadmapService.getRoadmapItems()
            columns = try await roadmapService.getRoadmapColumns()
            logInfo("RoadmapViewModel: Loaded \(items.count) items in \(columns.count) columns")
        } catch let err as AppGramError {
            logError("RoadmapViewModel: Failed to load roadmap - \(err.localizedDescription)")
            error = err
        } catch {
            logError("RoadmapViewModel: Network error loading roadmap - \(error.localizedDescription)")
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public var filteredItems: [RoadmapItem] {
        guard let category = selectedCategory else {
            return items
        }
        return items.filter { $0.category?.id == category.id }
    }

    public var filteredColumns: [RoadmapColumn] {
        guard let category = selectedCategory else {
            return columns
        }
        return columns.map { column in
            RoadmapColumn(
                status: column.status,
                items: column.items.filter { $0.category?.id == category.id }
            )
        }
    }

    public var plannedItems: [RoadmapItem] {
        filteredItems.filter { $0.status == .planned }
    }

    public var inProgressItems: [RoadmapItem] {
        filteredItems.filter { $0.status == .inProgress }
    }

    public var completedItems: [RoadmapItem] {
        filteredItems.filter { $0.status == .completed }
    }

    public var timelineItems: [RoadmapItem] {
        filteredItems.sorted { item1, item2 in
            let date1 = item1.targetDate ?? item1.createdAt
            let date2 = item2.targetDate ?? item2.createdAt
            return date1 < date2
        }
    }

    public func clearError() {
        error = nil
    }

    public func refresh() async {
        await loadRoadmap()
    }
}
