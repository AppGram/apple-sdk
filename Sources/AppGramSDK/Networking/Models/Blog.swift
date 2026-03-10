import Foundation

/// Represents a blog category.
///
/// ## Discussion
/// Blog categories are used to organize blog posts into logical groups.
/// Each category has a name, slug, and optional description and color.
///
/// ## Example
/// ```swift
/// let category = BlogCategory(
///     id: "cat123",
///     name: "News",
///     slug: "news",
///     description: "Latest updates and announcements",
///     color: "#3B82F6",
///     postCount: 15
/// )
/// ```
public struct BlogCategory: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the category.
    public let id: String

    /// The display name of the category.
    public let name: String

    /// The URL-friendly slug identifier.
    public let slug: String

    /// An optional description of the category.
    public let description: String?

    /// The color associated with this category (hex string).
    public let color: String?

    /// The number of posts in this category.
    public let postCount: Int?

    public init(
        id: String,
        name: String,
        slug: String,
        description: String?,
        color: String?,
        postCount: Int?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.color = color
        self.postCount = postCount
    }

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, color
        case postCount = "post_count"
    }
}

/// Represents a blog post.
///
/// ## Discussion
/// Blog posts contain content that can be displayed to users, including
/// title, content, excerpt, author information, and metadata.
///
/// ## Example
/// ```swift
/// let post = try await blogService.getBlogPost(slug: "welcome-post")
/// print(post.title)
/// ```
public struct BlogPost: Codable, Identifiable, Sendable {
    /// The unique identifier for the post.
    public let id: String

    /// The project ID this post belongs to.
    public let projectId: String

    /// The category ID this post belongs to.
    public let categoryId: String?

    /// The title of the post.
    public let title: String

    /// The URL-friendly slug identifier.
    public let slug: String

    /// The full content of the post (markdown or HTML).
    public let content: String

    /// A short excerpt of the post.
    public let excerpt: String?

    /// The meta description for SEO.
    public let metaDescription: String?

    /// The Open Graph image URL.
    public let ogImageUrl: String?

    /// The name of the author.
    public let authorName: String?

    /// The date when the post was published.
    public let publishedAt: Date?

    /// Whether this post is featured.
    public let isFeatured: Bool

    /// Tags associated with this post.
    public let tags: [String]

    /// The number of times this post has been viewed.
    public let viewCount: Int

    /// The date when the post was created.
    public let createdAt: Date?

    /// The date when the post was last updated.
    public let updatedAt: Date?

    /// The category this post belongs to (nested object).
    public let category: BlogCategoryRef?

    public init(
        id: String,
        projectId: String,
        categoryId: String?,
        title: String,
        slug: String,
        content: String,
        excerpt: String?,
        metaDescription: String?,
        ogImageUrl: String?,
        authorName: String?,
        publishedAt: Date?,
        isFeatured: Bool,
        tags: [String],
        viewCount: Int,
        createdAt: Date?,
        updatedAt: Date?,
        category: BlogCategoryRef?
    ) {
        self.id = id
        self.projectId = projectId
        self.categoryId = categoryId
        self.title = title
        self.slug = slug
        self.content = content
        self.excerpt = excerpt
        self.metaDescription = metaDescription
        self.ogImageUrl = ogImageUrl
        self.authorName = authorName
        self.publishedAt = publishedAt
        self.isFeatured = isFeatured
        self.tags = tags
        self.viewCount = viewCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.category = category
    }

    enum CodingKeys: String, CodingKey {
        case id, title, slug, content, excerpt, tags, category
        case projectId = "project_id"
        case categoryId = "category_id"
        case metaDescription = "meta_description"
        case ogImageUrl = "og_image_url"
        case authorName = "author_name"
        case publishedAt = "published_at"
        case isFeatured = "is_featured"
        case viewCount = "view_count"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        projectId = try container.decodeIfPresent(String.self, forKey: .projectId) ?? ""
        categoryId = try container.decodeIfPresent(String.self, forKey: .categoryId)
        title = try container.decode(String.self, forKey: .title)
        slug = try container.decode(String.self, forKey: .slug)
        content = try container.decodeIfPresent(String.self, forKey: .content) ?? ""
        excerpt = try container.decodeIfPresent(String.self, forKey: .excerpt)
        metaDescription = try container.decodeIfPresent(String.self, forKey: .metaDescription)
        ogImageUrl = try container.decodeIfPresent(String.self, forKey: .ogImageUrl)
        authorName = try container.decodeIfPresent(String.self, forKey: .authorName)
        publishedAt = try container.decodeIfPresent(Date.self, forKey: .publishedAt)

        // Handle is_featured as boolean or integer
        if let boolValue = try? container.decode(Bool.self, forKey: .isFeatured) {
            isFeatured = boolValue
        } else if let intValue = try? container.decode(Int.self, forKey: .isFeatured) {
            isFeatured = intValue != 0
        } else {
            isFeatured = false
        }

        tags = try container.decodeIfPresent([String].self, forKey: .tags) ?? []
        viewCount = try container.decodeIfPresent(Int.self, forKey: .viewCount) ?? 0
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        category = try container.decodeIfPresent(BlogCategoryRef.self, forKey: .category)
    }
}

/// A lightweight reference to a blog category (used in nested objects).
public struct BlogCategoryRef: Codable, Sendable, Hashable {
    /// The unique identifier for the category.
    public let id: String

    /// The display name of the category.
    public let name: String

    /// The URL-friendly slug identifier.
    public let slug: String

    /// The color associated with this category (hex string).
    public let color: String?

    public init(id: String, name: String, slug: String, color: String?) {
        self.id = id
        self.name = name
        self.slug = slug
        self.color = color
    }
}

/// Filters for querying blog posts.
///
/// ## Discussion
/// Use these filters to customize the blog posts query results.
///
/// ## Example
/// ```swift
/// let filters = BlogFilters(
///     categorySlug: "news",
///     search: "announcement",
///     page: 1,
///     perPage: 10
/// )
/// let posts = try await blogService.getBlogPosts(filters: filters)
/// ```
public struct BlogFilters: Sendable {
    /// Filter by category slug.
    public var categorySlug: String?

    /// Filter by tag.
    public var tag: String?

    /// Search query.
    public var search: String?

    /// Filter to featured posts only.
    public var isFeatured: Bool?

    /// Current page number.
    public var page: Int

    /// Number of items per page.
    public var perPage: Int

    public init(
        categorySlug: String? = nil,
        tag: String? = nil,
        search: String? = nil,
        isFeatured: Bool? = nil,
        page: Int = 1,
        perPage: Int = 10
    ) {
        self.categorySlug = categorySlug
        self.tag = tag
        self.search = search
        self.isFeatured = isFeatured
        self.page = page
        self.perPage = perPage
    }
}

// MARK: - Response Types

/// Response wrapper for paginated blog posts.
internal struct BlogPostsResponse: Decodable, Sendable {
    let data: [BlogPost]
    let total: Int
    let page: Int
    let perPage: Int
    let totalPages: Int

    enum CodingKeys: String, CodingKey {
        case data, total, page
        case perPage = "per_page"
        case totalPages = "total_pages"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        data = try container.decodeIfPresent([BlogPost].self, forKey: .data) ?? []
        total = try container.decodeIfPresent(Int.self, forKey: .total) ?? 0
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        perPage = try container.decodeIfPresent(Int.self, forKey: .perPage) ?? 10
        totalPages = try container.decodeIfPresent(Int.self, forKey: .totalPages) ?? 1
    }
}

/// API response wrapper for blog posts list (handles success wrapper).
internal struct BlogPostsAPIResponse: Decodable, Sendable {
    let success: Bool?
    let data: [BlogPost]?
    let total: Int?
    let page: Int?
    let perPage: Int?
    let totalPages: Int?

    enum CodingKeys: String, CodingKey {
        case success, data, total, page
        case perPage = "per_page"
        case totalPages = "total_pages"
    }
}

/// Paginated result for blog posts.
public struct PaginatedBlogPosts: Sendable {
    /// The list of blog posts.
    public let posts: [BlogPost]

    /// Total number of posts matching the query.
    public let total: Int

    /// Current page number.
    public let page: Int

    /// Number of items per page.
    public let perPage: Int

    /// Total number of pages.
    public let totalPages: Int

    public init(
        posts: [BlogPost],
        total: Int,
        page: Int,
        perPage: Int,
        totalPages: Int
    ) {
        self.posts = posts
        self.total = total
        self.page = page
        self.perPage = perPage
        self.totalPages = totalPages
    }
}
