import Foundation

/// Protocol for interacting with blog/resources functionality.
///
/// ## Discussion
/// The blog service provides methods to fetch blog posts, categories,
/// and search functionality for content management.
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getBlogService()
/// let posts = try await service.getBlogPosts()
/// ```
public protocol BlogServiceProtocol: Sendable {
    /// Get paginated blog posts with optional filters.
    func getBlogPosts(filters: BlogFilters?) async throws -> PaginatedBlogPosts

    /// Get a single blog post by slug.
    func getBlogPost(slug: String) async throws -> BlogPost

    /// Get featured blog posts.
    func getFeaturedBlogPosts() async throws -> [BlogPost]

    /// Get all blog categories.
    func getBlogCategories() async throws -> [BlogCategory]

    /// Get blog posts by category slug.
    func getBlogPostsByCategory(categorySlug: String, page: Int, perPage: Int) async throws -> PaginatedBlogPosts

    /// Get blog posts by tag.
    func getBlogPostsByTag(tag: String, page: Int, perPage: Int) async throws -> PaginatedBlogPosts

    /// Search blog posts.
    func searchBlogPosts(query: String, page: Int, perPage: Int) async throws -> PaginatedBlogPosts

    /// Get related blog posts for a given post.
    func getRelatedBlogPosts(slug: String) async throws -> [BlogPost]
}

internal actor BlogService: BlogServiceProtocol {
    private let apiClient: APIClient
    private let projectId: String
    private let cache = Cache<String, Any>(defaultTTL: 300) // 5 minute cache

    public init(
        apiClient: APIClient,
        projectId: String
    ) {
        self.apiClient = apiClient
        self.projectId = projectId
    }

    public func getBlogPosts(filters: BlogFilters? = nil) async throws -> PaginatedBlogPosts {
        let effectiveFilters = filters ?? BlogFilters()
        logDebug("BlogService: Getting blog posts with filters - page: \(effectiveFilters.page), perPage: \(effectiveFilters.perPage)")

        let response: BlogPostsAPIResponse = try await apiClient.get(
            endpoint: .blogPosts(projectId: projectId),
            blogFilters: effectiveFilters
        )

        let posts = response.data ?? []
        logInfo("BlogService: Fetched \(posts.count) blog posts")

        return PaginatedBlogPosts(
            posts: posts,
            total: response.total ?? posts.count,
            page: response.page ?? effectiveFilters.page,
            perPage: response.perPage ?? effectiveFilters.perPage,
            totalPages: response.totalPages ?? 1
        )
    }

    public func getBlogPost(slug: String) async throws -> BlogPost {
        logDebug("BlogService: Getting blog post with slug: \(slug)")

        let response: APIResponse<BlogPost> = try await apiClient.get(
            endpoint: .blogPost(projectId: projectId, slug: slug)
        )

        logInfo("BlogService: Fetched blog post: \(response.data.title)")
        return response.data
    }

    public func getFeaturedBlogPosts() async throws -> [BlogPost] {
        let cacheKey = "featured_posts"
        if let cached = await cache.get(key: cacheKey) as? [BlogPost] {
            logDebug("BlogService: Returning cached featured posts")
            return cached
        }

        logDebug("BlogService: Getting featured blog posts")

        let response: APIResponse<[BlogPost]> = try await apiClient.get(
            endpoint: .blogFeatured(projectId: projectId)
        )

        logInfo("BlogService: Fetched \(response.data.count) featured blog posts")
        await cache.set(key: cacheKey, value: response.data)
        return response.data
    }

    public func getBlogCategories() async throws -> [BlogCategory] {
        let cacheKey = "categories"
        if let cached = await cache.get(key: cacheKey) as? [BlogCategory] {
            logDebug("BlogService: Returning cached categories")
            return cached
        }

        logDebug("BlogService: Getting blog categories")

        let response: APIResponse<[BlogCategory]> = try await apiClient.get(
            endpoint: .blogCategories(projectId: projectId)
        )

        logInfo("BlogService: Fetched \(response.data.count) blog categories")
        await cache.set(key: cacheKey, value: response.data)
        return response.data
    }

    public func getBlogPostsByCategory(categorySlug: String, page: Int = 1, perPage: Int = 10) async throws -> PaginatedBlogPosts {
        logDebug("BlogService: Getting blog posts for category: \(categorySlug)")

        let response: BlogPostsAPIResponse = try await apiClient.get(
            endpoint: .blogByCategory(projectId: projectId, categorySlug: categorySlug),
            blogFilters: BlogFilters(page: page, perPage: perPage)
        )

        let posts = response.data ?? []
        logInfo("BlogService: Fetched \(posts.count) blog posts for category: \(categorySlug)")

        return PaginatedBlogPosts(
            posts: posts,
            total: response.total ?? posts.count,
            page: response.page ?? page,
            perPage: response.perPage ?? perPage,
            totalPages: response.totalPages ?? 1
        )
    }

    public func getBlogPostsByTag(tag: String, page: Int = 1, perPage: Int = 10) async throws -> PaginatedBlogPosts {
        logDebug("BlogService: Getting blog posts for tag: \(tag)")

        let response: BlogPostsAPIResponse = try await apiClient.get(
            endpoint: .blogByTag(projectId: projectId, tag: tag),
            blogFilters: BlogFilters(page: page, perPage: perPage)
        )

        let posts = response.data ?? []
        logInfo("BlogService: Fetched \(posts.count) blog posts for tag: \(tag)")

        return PaginatedBlogPosts(
            posts: posts,
            total: response.total ?? posts.count,
            page: response.page ?? page,
            perPage: response.perPage ?? perPage,
            totalPages: response.totalPages ?? 1
        )
    }

    public func searchBlogPosts(query: String, page: Int = 1, perPage: Int = 10) async throws -> PaginatedBlogPosts {
        logDebug("BlogService: Searching blog posts with query: \(query)")

        let response: BlogPostsAPIResponse = try await apiClient.get(
            endpoint: .blogSearch(projectId: projectId, query: query),
            blogFilters: BlogFilters(page: page, perPage: perPage)
        )

        let posts = response.data ?? []
        logInfo("BlogService: Found \(posts.count) blog posts matching query: \(query)")

        return PaginatedBlogPosts(
            posts: posts,
            total: response.total ?? posts.count,
            page: response.page ?? page,
            perPage: response.perPage ?? perPage,
            totalPages: response.totalPages ?? 1
        )
    }

    public func getRelatedBlogPosts(slug: String) async throws -> [BlogPost] {
        logDebug("BlogService: Getting related posts for: \(slug)")

        let response: OptionalAPIResponse<[BlogPost]> = try await apiClient.get(
            endpoint: .blogRelated(projectId: projectId, slug: slug)
        )

        let posts = response.data ?? []
        logInfo("BlogService: Fetched \(posts.count) related blog posts")
        return posts
    }
}
