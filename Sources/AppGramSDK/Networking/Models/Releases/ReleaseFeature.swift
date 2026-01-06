import Foundation

/// Represents a feature included in a release.
///
/// ## Discussion
/// Release features highlight specific improvements, additions, or changes
/// that are part of a release. They can include descriptions and images.
///
/// ## Example
/// ```swift
/// let feature = ReleaseFeature(
///     id: "feature123",
///     title: "Dark Mode",
///     description: "Added dark mode support throughout the app",
///     imageUrl: "https://example.com/dark-mode.png",
///     sortOrder: 1,
///     createdAt: Date(),
///     updatedAt: Date()
/// )
/// ```
public struct ReleaseFeature: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the feature.
    public let id: String
    
    /// The title of the feature.
    public let title: String
    
    /// An optional description of the feature.
    public let description: String?
    
    /// The URL of an image showcasing the feature.
    public let imageUrl: String?
    
    /// The display order of this feature.
    public let sortOrder: Int?
    
    /// The date when the feature was created.
    public let createdAt: Date
    
    /// The date when the feature was last updated.
    public let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case imageUrl = "image_url"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: ReleaseFeature, rhs: ReleaseFeature) -> Bool {
        lhs.id == rhs.id
    }
}
