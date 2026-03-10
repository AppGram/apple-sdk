import Foundation

/// Represents an item on the product roadmap.
///
/// ## Discussion
/// Roadmap items are features or improvements that are planned, in progress, or completed.
/// They are similar to wishes but are specifically displayed in the roadmap view
/// and may have target dates for completion.
///
/// ## Example
/// ```swift
/// let item = RoadmapItem(
///     id: "item123",
///     title: "Dark Mode",
///     description: "Add dark mode support",
///     status: .inProgress,
///     voteCount: 150,
///     commentCount: 25,
///     category: category,
///     targetDate: Date().addingTimeInterval(86400 * 30),
///     completedAt: nil,
///     createdAt: Date()
/// )
/// ```
public struct RoadmapItem: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the roadmap item.
    public let id: String
    
    /// The title of the roadmap item.
    public let title: String
    
    /// An optional detailed description.
    public let description: String?
    
    /// The current status of the roadmap item.
    public let status: WishStatus
    
    /// The number of votes this item has received.
    public let voteCount: Int
    
    /// The number of comments on this item.
    public let commentCount: Int
    
    /// The category this item belongs to, if any.
    public let category: Category?
    
    /// The target date for completion, if set.
    public let targetDate: Date?
    
    /// The date when the item was completed, if applicable.
    public let completedAt: Date?
    
    /// The date when the item was created.
    public let createdAt: Date

    public init(
        id: String,
        title: String,
        description: String?,
        status: WishStatus,
        voteCount: Int,
        commentCount: Int,
        category: Category?,
        targetDate: Date?,
        completedAt: Date?,
        createdAt: Date
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.status = status
        self.voteCount = voteCount
        self.commentCount = commentCount
        self.category = category
        self.targetDate = targetDate
        self.completedAt = completedAt
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, status, category
        case voteCount = "vote_count"
        case commentCount = "comment_count"
        case targetDate = "target_date"
        case completedAt = "completed_at"
        case createdAt = "created_at"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: RoadmapItem, rhs: RoadmapItem) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents a column in a kanban-style roadmap view.
///
/// ## Discussion
/// Roadmap columns group items by their status, allowing for kanban board
/// visualization of the roadmap.
///
/// ## Example
/// ```swift
/// let column = RoadmapColumn(
///     status: .planned,
///     items: [item1, item2, item3]
/// )
/// ```
public struct RoadmapColumn: Identifiable, Sendable {
    /// The unique identifier for the column (same as status raw value).
    public let id: String
    
    /// The status that this column represents.
    public let status: WishStatus
    
    /// The roadmap items in this column.
    public let items: [RoadmapItem]

    public init(status: WishStatus, items: [RoadmapItem]) {
        self.id = status.rawValue
        self.status = status
        self.items = items
    }
}

/// Layout options for displaying the roadmap.
///
/// ## Discussion
/// Defines the different visual layouts available for roadmap views.
///
/// ## Example
/// ```swift
/// let layout: RoadmapLayout = .kanban
/// ```
public enum RoadmapLayout: String, CaseIterable, Sendable {
    /// Display items in a kanban board with columns by status.
    case kanban
    
    /// Display items in a timeline view.
    case timeline
    
    /// Display items in a simple list view.
    case list

    public var displayName: String {
        switch self {
        case .kanban:
            return "Kanban"
        case .timeline:
            return "Timeline"
        case .list:
            return "List"
        }
    }

    public var systemImageName: String {
        switch self {
        case .kanban:
            return "square.grid.2x2"
        case .timeline:
            return "calendar"
        case .list:
            return "list.bullet"
        }
    }
}
