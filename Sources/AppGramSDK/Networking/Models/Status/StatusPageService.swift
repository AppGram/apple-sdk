import Foundation

/// Represents a service being monitored on a status page.
///
/// ## Discussion
/// Status page services are individual components or services that are tracked
/// for their operational status. They can be grouped and displayed with custom colors.
///
/// ## Example
/// ```swift
/// let service = StatusPageService(
///     id: "service123",
///     name: "API Service",
///     description: "Main API endpoint",
///     status: .operational,
///     color: "#10b981",
///     groupName: "Core Services",
///     isActive: true,
///     sortOrder: 1,
///     createdAt: Date(),
///     updatedAt: Date()
/// )
/// ```
public struct StatusPageService: Codable, Identifiable, Sendable {
    /// The unique identifier for the service.
    public let id: String
    
    /// The display name of the service.
    public let name: String
    
    /// An optional description of the service.
    public let description: String?
    
    /// The current operational status of the service.
    public let status: StatusType?
    
    /// An optional color code for displaying the service.
    public let color: String?
    
    /// The name of the group this service belongs to.
    public let groupName: String?
    
    /// Whether the service is currently being monitored.
    public let isActive: Bool?
    
    /// The display order of this service.
    public let sortOrder: Int?
    
    /// The date when the service was created.
    public let createdAt: Date
    
    /// The date when the service was last updated.
    public let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id, name, description, status, color
        case groupName = "group_name"
        case isActive = "is_active"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
