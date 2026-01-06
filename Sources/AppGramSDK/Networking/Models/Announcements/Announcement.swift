import Foundation

/// Represents an announcement to be displayed to users.
///
/// ## Discussion
/// Announcements are typically based on the latest app releases and highlight
/// new features, improvements, or important updates. They are designed to be
/// shown in a modal presentation on app launch or when manually triggered.
///
/// ## Example
/// ```swift
/// let announcement = Announcement(
///     id: "release123",
///     title: "Version 2.0",
///     subtitle: "Exciting new features",
///     features: [feature1, feature2],
///     version: "2.0.0",
///     imageUrl: "https://example.com/preview.png",
///     privacyNote: nil,
///     learnMoreUrl: nil
/// )
/// ```
public struct Announcement: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the announcement.
    public let id: String

    /// The title of the announcement (e.g., "Introducing agent mode").
    public let title: String

    /// An optional subtitle providing additional context.
    public let subtitle: String?

    /// The list of features or highlights to display.
    public let features: [AnnouncementFeature]

    /// The version associated with this announcement.
    public let version: String?

    /// An optional preview image URL.
    public let imageUrl: String?

    /// An optional privacy notice to display.
    public let privacyNote: String?

    /// An optional URL for "Learn more" link.
    public let learnMoreUrl: String?

    /// The date when the announcement was created.
    public let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, features, version
        case imageUrl = "image_url"
        case privacyNote = "privacy_note"
        case learnMoreUrl = "learn_more_url"
        case createdAt = "created_at"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: Announcement, rhs: Announcement) -> Bool {
        lhs.id == rhs.id
    }

    /// Creates an announcement from a release.
    ///
    /// - Parameter release: The release to convert to an announcement.
    /// - Returns: An announcement based on the release data.
    public static func from(release: Release) -> Announcement {
        let features = (release.features ?? []).map { releaseFeature in
            AnnouncementFeature(
                id: releaseFeature.id,
                title: releaseFeature.title,
                description: releaseFeature.description,
                imageUrl: releaseFeature.imageUrl
            )
        }

        return Announcement(
            id: release.id,
            title: release.title,
            subtitle: release.excerpt,
            features: features,
            version: release.version,
            imageUrl: release.coverImageUrl,
            privacyNote: nil,
            learnMoreUrl: nil,
            createdAt: release.createdAt
        )
    }
}
