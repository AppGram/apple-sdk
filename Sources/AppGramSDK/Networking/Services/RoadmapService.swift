import Foundation

/// Protocol for interacting with roadmap functionality.
///
/// ## Discussion
/// The roadmap service provides methods to retrieve roadmap items and organize
/// them into columns for kanban-style displays.
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getRoadmapService()
/// let columns = try await service.getRoadmapColumns()
/// ```
public protocol RoadmapServiceProtocol: Sendable {
    func getRoadmapItems() async throws -> [RoadmapItem]
    func getRoadmapColumns() async throws -> [RoadmapColumn]
}

internal actor RoadmapService: RoadmapServiceProtocol {
    private let apiClient: APIClient
    private let projectId: String
    private let cache: Cache<String, [RoadmapItem]>

    public init(apiClient: APIClient, projectId: String) {
        self.apiClient = apiClient
        self.projectId = projectId
        self.cache = Cache(defaultTTL: 300)
    }

    public func getRoadmapItems() async throws -> [RoadmapItem] {
        logDebug("Getting roadmap items")
        let cacheKey = "roadmap-items"

        if let cached = await cache.get(key: cacheKey) {
            logDebug("Returning \(cached.count) cached roadmap items")
            return cached
        }

        let apiResponse: RoadmapAPIResponse = try await apiClient.get(
            endpoint: .roadmap(projectId: projectId)
        )

        // Extract roadmap items from wishes array
        // Create a map of wish IDs to target dates from roadmap columns
        var wishTargetDates: [String: Date] = [:]
        if let roadmap = apiResponse.data.roadmap {
            for column in roadmap.columns {
                for item in column.items {
                    // Get wish ID from either the wish object or use the item ID
                    let wishId = item.wish?.id ?? item.id
                    if let targetDateStr = item.targetDate {
                        // Parse date in YYYY-MM-DD format
                        let formatter = DateFormatter()
                        formatter.dateFormat = "yyyy-MM-dd"
                        formatter.timeZone = TimeZone(secondsFromGMT: 0)
                        formatter.locale = Locale(identifier: "en_US_POSIX")
                        if let date = formatter.date(from: targetDateStr) {
                            wishTargetDates[wishId] = date
                        }
                    }
                }
            }
        }

        // Convert wishes to roadmap items
        let roadmapItems = apiResponse.data.wishes.map { wish -> RoadmapItem in
            let targetDate = wishTargetDates[wish.id]
            return RoadmapItem(
                id: wish.id,
                title: wish.title,
                description: wish.description,
                status: wish.status,
                voteCount: wish.voteCount,
                commentCount: wish.commentCount,
                category: wish.category,
                targetDate: targetDate,
                completedAt: wish.completedAt,
                createdAt: wish.createdAt
            )
        }

        logInfo("Fetched \(roadmapItems.count) roadmap items from API")
        await cache.set(key: cacheKey, value: roadmapItems)
        return roadmapItems
    }

    public func getRoadmapColumns() async throws -> [RoadmapColumn] {
        logDebug("Getting roadmap columns")
        let items = try await getRoadmapItems()

        let roadmapStatuses: [WishStatus] = [.planned, .inProgress, .completed]

        let columns = roadmapStatuses.map { status in
            RoadmapColumn(
                status: status,
                items: items.filter { $0.status == status }
            )
        }

        logDebug("Created \(columns.count) roadmap columns")
        return columns
    }
}
