import Foundation
import SwiftUI

/// Represents the operational status of a service.
///
/// ## Discussion
/// Status types indicate the current state of a service, from fully operational
/// to various levels of issues or maintenance.
///
/// ## Example
/// ```swift
/// let status: StatusType = .operational
/// ```
public enum StatusType: String, Codable, CaseIterable, Sendable {
    /// The service is fully operational.
    case operational
    
    /// The service is under maintenance.
    case maintenance
    
    /// The service is experiencing degraded performance.
    case degraded = "degraded_performance"
    
    /// The service has a partial outage.
    case partialOutage = "partial_outage"
    
    /// The service has a major outage.
    case majorOutage = "major_outage"
    
    /// There is an active incident affecting the service.
    case incident

    public var displayName: String {
        switch self {
        case .operational:
            return "Operational"
        case .maintenance:
            return "Maintenance"
        case .degraded:
            return "Degraded Performance"
        case .partialOutage:
            return "Partial Outage"
        case .majorOutage:
            return "Major Outage"
        case .incident:
            return "Incident"
        }
    }

    public var color: Color {
        switch self {
        case .operational:
            return .green
        case .maintenance:
            return .blue
        case .degraded:
            return .yellow
        case .partialOutage:
            return .orange
        case .majorOutage:
            return .red
        case .incident:
            return .red
        }
    }

    public var iconName: String {
        switch self {
        case .operational:
            return "checkmark.circle.fill"
        case .maintenance:
            return "wrench.and.screwdriver.fill"
        case .degraded:
            return "exclamationmark.triangle.fill"
        case .partialOutage:
            return "exclamationmark.circle.fill"
        case .majorOutage:
            return "xmark.circle.fill"
        case .incident:
            return "exclamationmark.octagon.fill"
        }
    }
}
