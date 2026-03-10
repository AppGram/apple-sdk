import Foundation

/// Represents a feature highlight within an announcement.
///
/// ## Discussion
/// Announcement features are the key items displayed in an announcement,
/// highlighting specific improvements, additions, or changes.
///
/// ## Example
/// ```swift
/// let feature = AnnouncementFeature(
///     id: "feature123",
///     title: "Dark Mode",
///     description: "Added dark mode support throughout the app",
///     imageUrl: "https://example.com/dark-mode.png"
/// )
/// ```
public struct AnnouncementFeature: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the feature.
    public let id: String

    /// The title of the feature.
    public let title: String

    /// An optional description of the feature.
    public let description: String?

    /// An optional image URL showcasing the feature.
    public let imageUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title, description
        case imageUrl = "image_url"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: AnnouncementFeature, rhs: AnnouncementFeature) -> Bool {
        lhs.id == rhs.id
    }
}
