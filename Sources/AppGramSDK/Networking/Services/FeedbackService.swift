import Foundation

/// Protocol for interacting with feedback-related functionality.
///
/// ## Discussion
/// The feedback service provides methods to manage user feedback (wishes), including
/// creating feedback items, voting, commenting, and retrieving categories.
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getFeedbackService()
/// let wishes = try await service.getWishes(filters: nil)
/// ```
public protocol FeedbackServiceProtocol: Sendable {
    func getWishes(filters: WishFilters?) async throws -> [Wish]
    func getWish(id: String) async throws -> Wish
    func createWish(title: String, description: String?, categoryId: String?) async throws -> Wish
    func addVote(wishId: String) async throws -> Vote
    func removeVote(wishId: String) async throws
    func getComments(wishId: String) async throws -> [Comment]
    func addComment(wishId: String, content: String) async throws -> Comment
    func getCategories() async throws -> [Category]
}

internal actor FeedbackService: FeedbackServiceProtocol {
    private let apiClient: APIClient
    private let projectId: String
    private let userContextProvider: @Sendable () -> UserContext?
    private let wishCache: Cache<String, [Wish]>
    private let categoryCache: Cache<String, [Category]>

    public init(
        apiClient: APIClient,
        projectId: String,
        userContextProvider: @escaping @Sendable () -> UserContext?
    ) {
        self.apiClient = apiClient
        self.projectId = projectId
        self.userContextProvider = userContextProvider
        self.wishCache = Cache(defaultTTL: 300)
        self.categoryCache = Cache(defaultTTL: 3600)
    }

    public func getWishes(filters: WishFilters?) async throws -> [Wish] {
        logDebug("Getting wishes with filters: \(String(describing: filters))")
        let cacheKey = "wishes-\(filters?.status?.rawValue ?? "all")-\(filters?.categoryId ?? "all")"

        if filters?.searchQuery == nil, let cached = await wishCache.get(key: cacheKey) {
            logDebug("Returning \(cached.count) cached wishes")
            return cached
        }

        let response: WishesResponse = try await apiClient.get(
            endpoint: .wishes(projectId: projectId),
            filters: filters
        )

        logInfo("Fetched \(response.wishes.count) wishes from API")

        if filters?.searchQuery == nil {
            await wishCache.set(key: cacheKey, value: response.wishes)
        }

        return response.wishes
    }

    public func getWish(id: String) async throws -> Wish {
        logDebug("Getting wish with id: \(id)")
        let response: APIResponse<Wish> = try await apiClient.get(endpoint: .wish(id: id))
        logDebug("Fetched wish: \(response.data.title)")
        return response.data
    }

    public func createWish(title: String, description: String?, categoryId: String?) async throws -> Wish {
        logInfo("Creating wish with title: \(title), categoryId: \(String(describing: categoryId))")
        let userContext = userContextProvider()

        let request = CreateWishRequest(
            title: title,
            description: description,
            categoryId: categoryId,
            projectId: projectId,
            userId: userContext?.userId,
            authorName: userContext?.name,
            authorEmail: userContext?.email
        )

        let response: APIResponse<Wish> = try await apiClient.post(endpoint: .createWish, body: request)
        logInfo("Successfully created wish with id: \(response.data.id)")
        await wishCache.clear()
        return response.data
    }

    public func addVote(wishId: String) async throws -> Vote {
        logDebug("Adding vote for wish: \(wishId)")
        let userContext = userContextProvider()
        let fingerprint = await DeviceFingerprint.shared.generate()

        let request = VoteRequest(
            wishId: wishId,
            projectId: projectId,
            userId: userContext?.userId,
            fingerprint: userContext?.isAnonymous == true ? fingerprint : nil
        )

        let response: APIResponse<Vote> = try await apiClient.post(endpoint: .vote, body: request)
        logInfo("Successfully added vote for wish: \(wishId)")
        await wishCache.clear()
        return response.data
    }

    public func removeVote(wishId: String) async throws {
        logDebug("Removing vote for wish: \(wishId)")
        try await apiClient.delete(endpoint: .removeVote(wishId: wishId))
        logInfo("Successfully removed vote for wish: \(wishId)")
        await wishCache.clear()
    }

    public func getComments(wishId: String) async throws -> [Comment] {
        logDebug("Getting comments for wish: \(wishId)")
        let response: CommentsResponse = try await apiClient.get(
            endpoint: .comments(wishId: wishId),
            wishId: wishId
        )
        logInfo("Fetched \(response.comments.count) comments for wish: \(wishId)")
        return response.comments
    }

    public func addComment(wishId: String, content: String) async throws -> Comment {
        logInfo("Adding comment to wish: \(wishId)")
        let userContext = userContextProvider()

        let request = CreateCommentRequest(
            content: content,
            wishId: wishId,
            projectId: projectId,
            userId: userContext?.userId,
            authorName: userContext?.name,
            authorEmail: userContext?.email
        )

        let response: APIResponse<Comment> = try await apiClient.post(endpoint: .createComment, body: request)
        logInfo("Successfully added comment to wish: \(wishId)")
        return response.data
    }

    public func getCategories() async throws -> [Category] {
        logDebug("Getting categories")
        let cacheKey = "categories"

        if let cached = await categoryCache.get(key: cacheKey) {
            logDebug("Returning \(cached.count) cached categories")
            return cached
        }

        let response: CategoriesResponse = try await apiClient.get(
            endpoint: .categories(projectId: projectId)
        )

        logInfo("Fetched \(response.categories.count) categories from API")
        await categoryCache.set(key: cacheKey, value: response.categories)
        return response.categories
    }
}

struct CreateWishRequest: Encodable {
    let title: String
    let description: String?
    let categoryId: String?
    let projectId: String
    let userId: String?
    let authorName: String?
    let authorEmail: String?

    enum CodingKeys: String, CodingKey {
        case title, description
        case categoryId = "category_id"
        case projectId = "project_id"
        case userId = "user_id"
        case authorName = "author_name"
        case authorEmail = "author_email"
    }
}
