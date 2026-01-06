import Foundation

/// Represents a category for organizing feedback items.
///
/// ## Discussion
/// Categories help organize and filter feedback items (wishes) in the feedback system.
/// Each category can have a name, description, color, and optional metadata.
///
/// ## Example
/// ```swift
/// let category = Category(
///     id: "cat123",
///     name: "Feature Requests",
///     slug: "feature-requests",
///     description: "Suggestions for new features",
///     color: "#3B82F6"
/// )
/// ```
public struct Category: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the category.
    public let id: String
    
    /// The display name of the category.
    public let name: String
    
    /// The URL-friendly identifier for the category.
    public let slug: String
    
    /// An optional description of the category.
    public let description: String?
    
    /// An optional color code (hex format) for the category.
    public let color: String?
    
    /// The project ID this category belongs to.
    public let projectId: String?
    
    /// The date when the category was created.
    public let createdAt: Date?
    
    /// The date when the category was last updated.
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        slug: String,
        description: String? = nil,
        color: String? = nil,
        projectId: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.color = color
        self.projectId = projectId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, color
        case projectId = "project_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
