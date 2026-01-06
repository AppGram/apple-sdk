import Foundation

/// Represents a status update or incident notification.
///
/// ## Discussion
/// Status updates inform users about service issues, maintenance, or incidents.
/// They can be active (ongoing) or resolved, and may affect multiple services.
///
/// ## Example
/// ```swift
/// let update = StatusUpdate(
///     id: "update123",
///     title: "Scheduled Maintenance",
///     description: "Maintenance window from 2-4 AM",
///     statusType: .maintenance,
///     state: .active,
///     affectedServices: ["service1", "service2"],
///     startedAt: Date(),
///     resolvedAt: nil,
///     createdAt: Date(),
///     updatedAt: Date()
/// )
/// ```
public struct StatusUpdate: Codable, Identifiable, Sendable {
    /// The unique identifier for the status update.
    public let id: String
    
    /// The title of the status update.
    public let title: String
    
    /// A detailed description of the update or incident.
    public let description: String?
    
    /// The type of status (operational, maintenance, outage, etc.).
    public let statusType: StatusType
    
    /// Whether the update is currently active or has been resolved.
    public let state: State
    
    /// The list of service IDs affected by this update.
    public let affectedServices: [String]
    
    /// The date when the incident or maintenance started.
    public let startedAt: Date?
    
    /// The date when the incident or maintenance was resolved.
    public let resolvedAt: Date?
    
    /// The date when the status update was created.
    public let createdAt: Date
    
    /// The date when the status update was last updated.
    public let updatedAt: Date

    /// The state of a status update.
    public enum State: String, Codable, Sendable {
        /// The update is currently active.
        case active
        
        /// The update has been resolved.
        case resolved
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, state
        case statusType = "status_type"
        case affectedServices = "affected_services"
        case startedAt = "started_at"
        case resolvedAt = "resolved_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
