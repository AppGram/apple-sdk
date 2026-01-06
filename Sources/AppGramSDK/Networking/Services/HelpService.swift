import Foundation

/// Protocol for interacting with help center functionality.
///
/// ## Discussion
/// The help service provides methods to retrieve help articles, collections,
/// and flows for displaying documentation to users.
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getHelpService()
/// let collections = try await service.getCollections()
/// let flows = try await service.getFlows()
/// ```
public protocol HelpServiceProtocol: Sendable {
    func getCollections() async throws -> [HelpCollection]
    func getFlows() async throws -> [HelpFlow]
    func getArticles(searchQuery: String?) async throws -> [HelpArticle]
    func getArticle(slug: String) async throws -> HelpArticle
}

internal actor HelpService: HelpServiceProtocol {
    private let apiClient: APIClient
    private let projectId: String
    private let collectionsCache: Cache<String, [HelpCollection]>
    private let flowsCache: Cache<String, [HelpFlow]>

    public init(apiClient: APIClient, projectId: String) {
        self.apiClient = apiClient
        self.projectId = projectId
        self.collectionsCache = Cache(defaultTTL: 3600)
        self.flowsCache = Cache(defaultTTL: 3600)
    }

    public func getCollections() async throws -> [HelpCollection] {
        logDebug("Getting help collections")
        let cacheKey = "help-collections"

        if let cached = await collectionsCache.get(key: cacheKey) {
            logDebug("Returning \(cached.count) cached help collections")
            return cached
        }

        let response: HelpCollectionsResponse = try await apiClient.get(
            endpoint: .helpCollections(projectId: projectId)
        )

        logInfo("Fetched \(response.collections.count) help collections from API")
        await collectionsCache.set(key: cacheKey, value: response.collections)
        return response.collections
    }

    public func getFlows() async throws -> [HelpFlow] {
        logDebug("Getting help flows")
        let cacheKey = "help-flows"

        // Try to get from cache first
        if let cached = await flowsCache.get(key: cacheKey) {
            logDebug("Returning \(cached.count) cached help flows")
            return cached
        }

        let response: HelpCollectionsResponse = try await apiClient.get(
            endpoint: .helpCollections(projectId: projectId)
        )

        let flows = response.data.flows
        logInfo("Fetched \(flows.count) help flows from API")
        await flowsCache.set(key: cacheKey, value: flows)
        return flows
    }

    public func getArticles(searchQuery: String?) async throws -> [HelpArticle] {
        logDebug("Getting help articles, searchQuery: \(String(describing: searchQuery))")
        let response: HelpArticlesResponse = try await apiClient.get(
            endpoint: .helpArticles(projectId: projectId)
        )
        logInfo("Fetched \(response.articles.count) help articles")
        return response.articles
    }

    public func getArticle(slug: String) async throws -> HelpArticle {
        logDebug("Getting help article with slug: \(slug)")
        let response: APIResponse<HelpArticle> = try await apiClient.get(endpoint: .helpArticle(slug: slug))
        logDebug("Fetched help article: \(response.data.title)")
        return response.data
    }
}
