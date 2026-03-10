import Foundation

/// Represents a comment on a feedback item (wish).
///
/// ## Discussion
/// Comments allow users and support staff to discuss feedback items. Comments can be
/// marked as official (from support staff) to distinguish them from user comments.
///
/// ## Example
/// ```swift
/// let comment = Comment(
///     id: "comment123",
///     content: "Great idea! We'll consider this for our next release.",
///     wishId: "wish456",
///     userId: "user789",
///     authorName: "Support Team",
///     authorEmail: "support@example.com",
///     isOfficial: true,
///     createdAt: Date(),
///     updatedAt: nil
/// )
/// ```
public struct Comment: Codable, Identifiable, Sendable {
    /// The unique identifier for the comment.
    public let id: String
    
    /// The text content of the comment.
    public let content: String
    
    /// The ID of the wish this comment belongs to.
    public let wishId: String
    
    /// The optional user ID of the comment author.
    public let userId: String?
    
    /// The display name of the comment author.
    public let authorName: String?
    
    /// The email address of the comment author.
    public let authorEmail: String?
    
    /// Whether this comment is from official support staff.
    public let isOfficial: Bool
    
    /// The date when the comment was created.
    public let createdAt: Date
    
    /// The date when the comment was last updated.
    public let updatedAt: Date?

    public init(
        id: String,
        content: String,
        wishId: String,
        userId: String?,
        authorName: String?,
        authorEmail: String?,
        isOfficial: Bool,
        createdAt: Date,
        updatedAt: Date?
    ) {
        self.id = id
        self.content = content
        self.wishId = wishId
        self.userId = userId
        self.authorName = authorName
        self.authorEmail = authorEmail
        self.isOfficial = isOfficial
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, content
        case wishId = "wish_id"
        case userId = "user_id"
        case authorName = "author_name"
        case authorEmail = "author_email"
        case isOfficial = "is_official"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

/// A request to create a new comment on a feedback item.
///
/// ## Discussion
/// Use this structure when submitting a new comment to the API.
///
/// ## Example
/// ```swift
/// let request = CreateCommentRequest(
///     content: "This would be very helpful!",
///     wishId: "wish123",
///     projectId: "project456",
///     userId: "user789",
///     authorName: "John Doe",
///     authorEmail: "john@example.com"
/// )
/// ```
public struct CreateCommentRequest: Encodable, Sendable {
    /// The text content of the comment.
    public let content: String
    
    /// The ID of the wish to comment on.
    public let wishId: String
    
    /// The project ID.
    public let projectId: String
    
    /// The optional user ID of the comment author.
    public let userId: String?
    
    /// The display name of the comment author.
    public let authorName: String?
    
    /// The email address of the comment author.
    public let authorEmail: String?

    public init(
        content: String,
        wishId: String,
        projectId: String,
        userId: String?,
        authorName: String?,
        authorEmail: String?
    ) {
        self.content = content
        self.wishId = wishId
        self.projectId = projectId
        self.userId = userId
        self.authorName = authorName
        self.authorEmail = authorEmail
    }

    enum CodingKeys: String, CodingKey {
        case content
        case wishId = "wish_id"
        case projectId = "project_id"
        case userId = "user_id"
        case authorName = "author_name"
        case authorEmail = "author_email"
    }
}
