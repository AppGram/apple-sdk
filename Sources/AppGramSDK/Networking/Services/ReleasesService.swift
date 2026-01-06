import Foundation

/// Protocol for interacting with releases functionality.
///
/// ## Discussion
/// The releases service provides methods to retrieve release notes, version
/// information, and release features.
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getReleasesService()
/// let releases = try await service.getReleases(orgSlug: "my-org", projectSlug: "my-project", limit: 10)
/// ```
public protocol ReleasesServiceProtocol: Sendable {
    func getReleases(orgSlug: String, projectSlug: String, limit: Int) async throws -> [Release]
    func getRelease(orgSlug: String, projectSlug: String, releaseSlug: String) async throws -> Release
    func getReleaseFeatures(releaseId: String) async throws -> [ReleaseFeature]
}

internal actor ReleasesService: ReleasesServiceProtocol {
    private let apiClient: APIClient

    public init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    public func getReleases(orgSlug: String, projectSlug: String, limit: Int = 50) async throws -> [Release] {
        logDebug("Fetching releases for orgSlug: \(orgSlug), projectSlug: \(projectSlug), limit: \(limit)")
        let response: PaginatedAPIResponse<Release> = try await apiClient.get(
            endpoint: .releases(orgSlug: orgSlug, projectSlug: projectSlug, limit: limit)
        )
        return response.data
    }

    public func getRelease(orgSlug: String, projectSlug: String, releaseSlug: String) async throws -> Release {
        logDebug("Fetching release for orgSlug: \(orgSlug), projectSlug: \(projectSlug), releaseSlug: \(releaseSlug)")
        let response: APIResponse<Release> = try await apiClient.get(
            endpoint: .release(orgSlug: orgSlug, projectSlug: projectSlug, releaseSlug: releaseSlug)
        )
        return response.data
    }

    public func getReleaseFeatures(releaseId: String) async throws -> [ReleaseFeature] {
        logDebug("Fetching release features for releaseId: \(releaseId)")
        let response: PaginatedAPIResponse<ReleaseFeature> = try await apiClient.get(
            endpoint: .releaseFeatures(releaseId: releaseId)
        )
        return response.data
    }
}
