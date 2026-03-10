import Foundation

/// Represents the status of a feedback item (wish).
///
/// ## Discussion
/// The status tracks the lifecycle of a wish from initial submission through
/// review, planning, implementation, and completion or decline.
///
/// ## Example
/// ```swift
/// let wish = Wish(
///     id: "wish123",
///     title: "Feature request",
///     status: .planned
/// )
/// ```
public enum WishStatus: String, Codable, Sendable, CaseIterable {
    /// The wish is pending review.
    case pending = "pending"
    
    /// The wish is under review by the team.
    case underReview = "under_review"
    
    /// The wish has been planned for implementation.
    case planned = "planned"
    
    /// The wish is currently being worked on.
    case inProgress = "in_progress"
    
    /// The wish has been completed.
    case completed = "completed"
    
    /// The wish has been declined and will not be implemented.
    case declined = "declined"

    public var displayName: String {
        switch self {
        case .pending:
            return "Pending"
        case .underReview:
            return "Under Review"
        case .planned:
            return "Planned"
        case .inProgress:
            return "In Progress"
        case .completed:
            return "Completed"
        case .declined:
            return "Declined"
        }
    }

    public var systemImageName: String {
        switch self {
        case .pending:
            return "clock"
        case .underReview:
            return "eye"
        case .planned:
            return "calendar"
        case .inProgress:
            return "hammer"
        case .completed:
            return "checkmark.circle"
        case .declined:
            return "xmark.circle"
        }
    }
}
