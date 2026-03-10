import Foundation

/// Protocol for interacting with status page functionality.
///
/// ## Discussion
/// The status service provides methods to retrieve status information, including
/// overall status overviews and individual service statuses.
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getStatusService()
/// let overview = try await service.getStatusOverview(projectId: "project123", slug: "status")
/// ```
public protocol StatusServiceProtocol: Sendable {
    func getStatusOverview(projectId: String, slug: String) async throws -> StatusOverview
    func getServices(statusPageId: String) async throws -> [StatusPageService]
}

internal actor StatusService: StatusServiceProtocol {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func getStatusOverview(projectId: String, slug: String) async throws -> StatusOverview {
        logDebug("Fetching status overview for projectId: \(projectId), slug: \(slug)")
        let response: APIResponse<StatusOverview> = try await apiClient.get(
            endpoint: .statusOverview(projectId: projectId, slug: slug)
        )
        return response.data
    }

    public func getServices(statusPageId: String) async throws -> [StatusPageService] {
        logDebug("Fetching status services for statusPageId: \(statusPageId)")
        let response: PaginatedAPIResponse<StatusPageService> = try await apiClient.get(
            endpoint: .statusServices(statusPageId: statusPageId)
        )
        return response.data
    }
}
