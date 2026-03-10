import Foundation

/// Represents a feedback item (wish) submitted by users.
///
/// ## Discussion
/// Wishes are user-submitted feedback items that can be voted on and commented on.
/// They represent feature requests, bug reports, or other feedback. Each wish has
/// a status that tracks its lifecycle from pending to completed.
///
/// ## Example
/// ```swift
/// let wish = Wish(
///     id: "wish123",
///     title: "Dark mode support",
///     description: "Please add dark mode to the app",
///     status: .planned,
///     voteCount: 42,
///     commentCount: 5,
///     category: category,
///     categoryId: "cat456",
///     authorName: "John Doe",
///     authorEmail: "john@example.com",
///     userId: "user789",
///     projectId: "project123",
///     createdAt: Date(),
///     updatedAt: nil,
///     completedAt: nil
/// )
/// ```
public struct Wish: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the wish.
    public let id: String
    
    /// The title of the wish.
    public let title: String
    
    /// An optional detailed description of the wish.
    public let description: String?
    
    /// The current status of the wish.
    public let status: WishStatus
    
    /// The number of votes this wish has received.
    public var voteCount: Int

    /// Whether the current user has voted on this wish.
    public var hasVoted: Bool

    /// The number of comments on this wish.
    public let commentCount: Int
    
    /// The category this wish belongs to, if any.
    public let category: Category?
    
    /// The ID of the category this wish belongs to.
    public let categoryId: String?
    
    /// The display name of the wish author.
    public let authorName: String?
    
    /// The email address of the wish author.
    public let authorEmail: String?
    
    /// The user ID of the wish author.
    public let userId: String?
    
    /// The project ID this wish belongs to.
    public let projectId: String
    
    /// The date when the wish was created.
    public let createdAt: Date
    
    /// The date when the wish was last updated.
    public let updatedAt: Date?
    
    /// The date when the wish was completed, if applicable.
    public let completedAt: Date?

    public init(
        id: String,
        title: String,
        description: String?,
        status: WishStatus,
        voteCount: Int,
        hasVoted: Bool = false,
        commentCount: Int,
        category: Category?,
        categoryId: String?,
        authorName: String?,
        authorEmail: String?,
        userId: String?,
        projectId: String,
        createdAt: Date,
        updatedAt: Date?,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.voteCount = voteCount
        self.hasVoted = hasVoted
        self.commentCount = commentCount
        self.category = category
        self.categoryId = categoryId
        self.authorName = authorName
        self.authorEmail = authorEmail
        self.userId = userId
        self.projectId = projectId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.completedAt = completedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, status, category
        case voteCount = "vote_count"
        case commentCount = "comment_count"
        case categoryId = "category_id"
        case authorName = "author_name"
        case authorEmail = "author_email"
        case userId = "author_user_id"
        case projectId = "project_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case completedAt = "completed_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        status = try container.decode(WishStatus.self, forKey: .status)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        hasVoted = false // Default to false, will be set programmatically
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        category = try container.decodeIfPresent(Category.self, forKey: .category)
        categoryId = try container.decodeIfPresent(String.self, forKey: .categoryId)
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
        authorEmail = try container.decodeIfPresent(String.self, forKey: .authorEmail)
        userId = try container.decodeIfPresent(String.self, forKey: .userId)
        projectId = try container.decode(String.self, forKey: .projectId)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        completedAt = try container.decodeIfPresent(Date.self, forKey: .completedAt)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encode(status, forKey: .status)
        try container.encode(voteCount, forKey: .voteCount)
        // hasVoted is not encoded - it's local state only
        try container.encode(commentCount, forKey: .commentCount)
        try container.encodeIfPresent(category, forKey: .category)
        try container.encodeIfPresent(categoryId, forKey: .categoryId)
        try container.encodeIfPresent(authorName, forKey: .authorName)
        try container.encodeIfPresent(authorEmail, forKey: .authorEmail)
        try container.encodeIfPresent(userId, forKey: .userId)
        try container.encode(projectId, forKey: .projectId)
        try container.encode(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(completedAt, forKey: .completedAt)
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Wish, rhs: Wish) -> Bool {
        lhs.id == rhs.id
    }
}

/// Filters and sorting options for querying wishes.
///
/// ## Discussion
/// Use this structure to filter and sort wishes when fetching them from the API.
/// All filter parameters are optional except for sortBy, page, and limit.
///
/// ## Example
/// ```swift
/// let filters = WishFilters(
///     status: .planned,
///     categoryId: "cat123",
///     searchQuery: "dark mode",
///     sortBy: .mostVotes,
///     page: 1,
///     limit: 20
/// )
/// ```
public struct WishFilters: Sendable {
    /// Filter by wish status.
    public var status: WishStatus?
    
    /// Filter by category ID.
    public var categoryId: String?
    
    /// Search query to filter wishes by title or description.
    public var searchQuery: String?
    
    /// The sorting option to apply.
    public var sortBy: WishSortOption
    
    /// The page number for pagination (1-based).
    public var page: Int
    
    /// The maximum number of wishes to return per page.
    public var limit: Int

    public init(
        status: WishStatus? = nil,
        categoryId: String? = nil,
        searchQuery: String? = nil,
        sortBy: WishSortOption = .newest,
        page: Int = 1,
        limit: Int = 50
    ) {
        self.status = status
        self.categoryId = categoryId
        self.searchQuery = searchQuery
        self.sortBy = sortBy
        self.page = page
        self.limit = limit
    }
}

/// Options for sorting wishes.
///
/// ## Discussion
/// Defines how wishes should be ordered when retrieved from the API.
///
/// ## Example
/// ```swift
/// let filters = WishFilters(sortBy: .mostVotes)
/// ```
public enum WishSortOption: String, Sendable, CaseIterable {
    /// Sort by creation date, newest first.
    case newest = "newest"
    
    /// Sort by creation date, oldest first.
    case oldest = "oldest"
    
    /// Sort by vote count, highest first.
    case mostVotes = "most_votes"
    
    /// Sort by vote count, lowest first.
    case leastVotes = "least_votes"

    public var displayName: String {
        switch self {
        case .newest:
            return "Newest"
        case .oldest:
            return "Oldest"
        case .mostVotes:
            return "Most Votes"
        case .leastVotes:
            return "Least Votes"
        }
    }
}
