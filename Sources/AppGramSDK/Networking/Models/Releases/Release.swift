import Foundation

/// Represents a product release or version update.
///
/// ## Discussion
/// Releases contain information about product updates, new features, bug fixes,
/// and other changes. They can include version numbers, labels, images, and
/// detailed feature lists.
///
/// ## Example
/// ```swift
/// let release = Release(
///     id: "release123",
///     title: "Version 2.0",
///     content: "# What's New\n\nMajor update...",
///     excerpt: "Major update with new features",
///     slug: "version-2-0",
///     version: "2.0.0",
///     labels: [.feature, .improvement],
///     coverImageUrl: "https://example.com/image.png",
///     publishedAt: Date(),
///     createdAt: Date(),
///     updatedAt: Date(),
///     features: [feature1, feature2]
/// )
/// ```
public struct Release: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the release.
    public let id: String
    
    /// The title of the release.
    public let title: String
    
    /// The full content of the release notes (may contain markdown or HTML).
    public let content: String?
    
    /// An optional excerpt or summary of the release.
    public let excerpt: String?
    
    /// The URL-friendly slug identifier.
    public let slug: String
    
    /// The version number of the release.
    public let version: String?
    
    /// The labels categorizing this release.
    public let labels: [ReleaseLabel]
    
    /// The URL of the cover image for the release.
    public let coverImageUrl: String?
    
    /// The date when the release was published.
    public let publishedAt: Date?
    
    /// The date when the release was created.
    public let createdAt: Date
    
    /// The date when the release was last updated.
    public let updatedAt: Date
    
    /// The list of features included in this release.
    public var features: [ReleaseFeature]?

    enum CodingKeys: String, CodingKey {
        case id, title, content, excerpt, slug, version, labels, features
        case coverImageUrl = "cover_image_url"
        case publishedAt = "published_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Release, rhs: Release) -> Bool {
        lhs.id == rhs.id
    }
}
