import Foundation

/// Represents the complete status overview for a status page.
///
/// ## Discussion
/// The status overview contains all information about the current state of services,
/// including the overall status, active incidents, and individual service statuses.
///
/// ## Example
/// ```swift
/// let overview = StatusOverview(
///     statusPage: statusPage,
///     currentStatus: .operational,
///     activeUpdates: [],
///     services: [service1, service2],
///     servicesStatus: ["service1": .operational, "service2": .degraded]
/// )
/// ```
public struct StatusOverview: Codable, Sendable {
    /// The status page information.
    public let statusPage: StatusPage

    /// The overall current status of all services.
    public let currentStatus: StatusType

    /// The list of active status updates or incidents.
    public let activeUpdates: [StatusUpdate]

    /// The list of services being monitored.
    public let services: [StatusPageService]?

    /// A dictionary mapping service IDs to their current status.
    public let servicesStatus: [String: StatusType]?

    enum CodingKeys: String, CodingKey {
        case statusPage = "status_page"
        case currentStatus = "current_status"
        case activeUpdates = "active_updates"
        case services
        case servicesStatus = "services_status"
    }
}

/// Represents a status page configuration.
///
/// ## Discussion
/// Status pages provide information about the operational status of services
/// and any ongoing incidents or maintenance.
///
/// ## Example
/// ```swift
/// let statusPage = StatusPage(
///     id: "page123",
///     name: "Service Status",
///     slug: "status",
///     description: "Current status of all services",
///     projectId: "project456",
///     createdAt: Date(),
///     updatedAt: Date()
/// )
/// ```
public struct StatusPage: Codable, Sendable {
    /// The unique identifier for the status page.
    public let id: String

    /// The display name of the status page.
    public let name: String

    /// The URL-friendly slug identifier.
    public let slug: String

    /// An optional description of the status page.
    public let description: String?

    /// The project ID this status page belongs to.
    public let projectId: String?

    /// The organization ID this status page belongs to.
    public let organizationId: String?

    /// The public URL for the status page.
    public let publicUrl: String?

    /// Whether the status page is active.
    public let isActive: Bool?

    /// The date when the status page was created.
    public let createdAt: Date?

    /// The date when the status page was last updated.
    public let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description
        case projectId = "project_id"
        case organizationId = "organization_id"
        case publicUrl = "public_url"
        case isActive = "is_active"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
