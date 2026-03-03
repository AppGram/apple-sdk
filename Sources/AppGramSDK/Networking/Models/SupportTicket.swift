import Foundation

/// Represents a support ticket submitted by a user.
///
/// ## Discussion
/// Support tickets allow users to report issues or request help. Each ticket has
/// a status, priority, and can contain multiple messages and attachments.
///
/// ## Example
/// ```swift
/// let ticket = SupportTicket(
///     id: "ticket123",
///     subject: "Login issue",
///     description: "Cannot log in to my account",
///     status: .open,
///     priority: .high,
///     userEmail: "user@example.com",
///     userName: "John Doe",
///     userId: "user456",
///     projectId: "project789",
///     messages: [],
///     attachments: nil,
///     createdAt: Date(),
///     updatedAt: nil
/// )
/// ```
public struct SupportTicket: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the ticket.
    public let id: String
    
    /// The subject line of the ticket.
    public let subject: String
    
    /// The detailed description of the issue.
    public let description: String
    
    /// The current status of the ticket.
    public let status: TicketStatus
    
    /// The priority level of the ticket.
    public let priority: TicketPriority
    
    /// The email address of the user who created the ticket.
    public let userEmail: String
    
    /// The display name of the user who created the ticket.
    public let userName: String?
    
    /// The user ID of the ticket creator.
    public let userId: String?
    
    /// The project ID this ticket belongs to.
    public let projectId: String
    
    /// The list of messages in this ticket's conversation.
    public let messages: [SupportMessage]?
    
    /// The list of file attachments.
    public let attachments: [Attachment]?
    
    /// The date when the ticket was created.
    public let createdAt: Date
    
    /// The date when the ticket was last updated.
    public let updatedAt: Date?

    public init(
        id: String,
        subject: String,
        description: String,
        status: TicketStatus,
        priority: TicketPriority,
        userEmail: String,
        userName: String?,
        userId: String?,
        projectId: String,
        messages: [SupportMessage]?,
        attachments: [Attachment]?,
        createdAt: Date,
        updatedAt: Date?
    ) {
        self.id = id
        self.subject = subject
        self.description = description
        self.status = status
        self.priority = priority
        self.userEmail = userEmail
        self.userName = userName
        self.userId = userId
        self.projectId = projectId
        self.messages = messages
        self.attachments = attachments
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, subject, description, status, priority, messages, attachments
        case userEmail = "user_email"
        case userName = "user_name"
        case userId = "user_id"
        case projectId = "project_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: SupportTicket, rhs: SupportTicket) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents the status of a support ticket.
///
/// ## Discussion
/// The status tracks the lifecycle of a support ticket from creation through
/// resolution and closure.
///
/// ## Example
/// ```swift
/// let status: TicketStatus = .open
/// ```
public enum TicketStatus: String, Codable, Sendable, CaseIterable {
    /// The ticket was just created.
    case new = "new"
    
    /// The ticket is open and awaiting response.
    case open = "open"
    
    /// The ticket is being worked on by support staff.
    case inProgress = "in_progress"
    
    /// The ticket is waiting for a response from the customer.
    case waitingOnCustomer = "waiting_on_customer"
    
    /// The ticket has been resolved.
    case resolved = "resolved"
    
    /// The ticket has been closed.
    case closed = "closed"

    public var displayName: String {
        switch self {
        case .new:
            return "New"
        case .open:
            return "Open"
        case .inProgress:
            return "In Progress"
        case .waitingOnCustomer:
            return "Waiting on Customer"
        case .resolved:
            return "Resolved"
        case .closed:
            return "Closed"
        }
    }

    public var systemImageName: String {
        switch self {
        case .new:
            return "envelope.badge"
        case .open:
            return "envelope.open"
        case .inProgress:
            return "clock"
        case .waitingOnCustomer:
            return "person.wave.2"
        case .resolved:
            return "checkmark.circle"
        case .closed:
            return "xmark.circle"
        }
    }
}

/// Represents the priority level of a support ticket.
///
/// ## Discussion
/// Priority levels help support teams prioritize which tickets to address first.
///
/// ## Example
/// ```swift
/// let priority: TicketPriority = .high
/// ```
public enum TicketPriority: String, Codable, Sendable, CaseIterable {
    /// Low priority ticket.
    case low = "low"
    
    /// Medium priority ticket.
    case medium = "medium"
    
    /// High priority ticket.
    case high = "high"
    
    /// Urgent priority ticket.
    case urgent = "urgent"

    public var displayName: String {
        switch self {
        case .low:
            return "Low"
        case .medium:
            return "Medium"
        case .high:
            return "High"
        case .urgent:
            return "Urgent"
        }
    }
}

/// Represents a message in a support ticket conversation.
///
/// ## Discussion
/// Messages are part of the conversation thread for a support ticket. They can
/// be from either the customer or support staff, and may include attachments.
///
/// ## Example
/// ```swift
/// let message = SupportMessage(
///     id: "msg123",
///     ticketId: "ticket456",
///     content: "We're looking into this issue.",
///     authorName: "Support Team",
///     authorEmail: "support@example.com",
///     isFromSupport: true,
///     attachments: nil,
///     createdAt: Date()
/// )
/// ```
public struct SupportMessage: Codable, Identifiable, Sendable {
    /// The unique identifier for the message.
    public let id: String
    
    /// The ID of the ticket this message belongs to.
    public let ticketId: String
    
    /// The text content of the message.
    public let content: String
    
    /// The display name of the message author.
    public let authorName: String?
    
    /// The email address of the message author.
    public let authorEmail: String?
    
    /// Whether this message is from support staff.
    public let isFromSupport: Bool
    
    /// The list of file attachments in this message.
    public let attachments: [Attachment]?
    
    /// The date when the message was created.
    public let createdAt: Date

    public init(
        id: String,
        ticketId: String,
        content: String,
        authorName: String?,
        authorEmail: String?,
        isFromSupport: Bool,
        attachments: [Attachment]?,
        createdAt: Date
    ) {
        self.id = id
        self.ticketId = ticketId
        self.content = content
        self.authorName = authorName
        self.authorEmail = authorEmail
        self.isFromSupport = isFromSupport
        self.attachments = attachments
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id, content, attachments
        case ticketId = "ticket_id"
        case authorName = "author_name"
        case authorEmail = "author_email"
        case isFromSupport = "is_from_support"
        case createdAt = "created_at"
    }
}

/// Represents a file attachment in a support ticket or message.
///
/// ## Discussion
/// Attachments can be added to support tickets or messages to provide additional
/// context such as screenshots, logs, or other files.
///
/// ## Example
/// ```swift
/// let attachment = Attachment(
///     id: "att123",
///     fileName: "screenshot.png",
///     fileUrl: "https://example.com/files/screenshot.png",
///     mimeType: "image/png",
///     fileSize: 102400
/// )
/// ```
public struct Attachment: Codable, Identifiable, Sendable {
    /// The unique identifier for the attachment.
    public let id: String
    
    /// The name of the file.
    public let fileName: String
    
    /// The URL where the file can be accessed.
    public let fileUrl: String
    
    /// The MIME type of the file.
    public let mimeType: String
    
    /// The size of the file in bytes.
    public let fileSize: Int?

    public init(
        id: String,
        fileName: String,
        fileUrl: String,
        mimeType: String,
        fileSize: Int?
    ) {
        self.id = id
        self.fileName = fileName
        self.fileUrl = fileUrl
        self.mimeType = mimeType
        self.fileSize = fileSize
    }

    enum CodingKeys: String, CodingKey {
        case id
        case fileName = "file_name"
        case fileUrl = "file_url"
        case mimeType = "mime_type"
        case fileSize = "file_size"
    }
}

/// A request to create a new support ticket.
///
/// ## Discussion
/// Use this structure when submitting a new support ticket to the API.
///
/// ## Example
/// ```swift
/// let request = CreateTicketRequest(
///     subject: "Login issue",
///     description: "Cannot log in",
///     priority: .high,
///     userEmail: "user@example.com",
///     userName: "John Doe",
///     userId: "user123",
///     projectId: "project456",
///     attachmentUrls: ["https://example.com/file.png"]
/// )
/// ```
public struct CreateTicketRequest: Encodable, Sendable {
    /// The subject line of the ticket.
    public let subject: String
    
    /// The detailed description of the issue.
    public let description: String
    
    /// The priority level of the ticket.
    public let priority: TicketPriority
    
    /// The email address of the user creating the ticket.
    public let userEmail: String
    
    /// The display name of the user creating the ticket.
    public let userName: String?
    
    /// The user ID of the ticket creator.
    public let userId: String?
    
    /// The project ID.
    public let projectId: String
    
    /// URLs of files to attach to the ticket.
    public let attachmentUrls: [String]?

    public init(
        subject: String,
        description: String,
        priority: TicketPriority,
        userEmail: String,
        userName: String?,
        userId: String?,
        projectId: String,
        attachmentUrls: [String]?
    ) {
        self.subject = subject
        self.description = description
        self.priority = priority
        self.userEmail = userEmail
        self.userName = userName
        self.userId = userId
        self.projectId = projectId
        self.attachmentUrls = attachmentUrls
    }

    enum CodingKeys: String, CodingKey {
        case subject, description, priority
        case userEmail = "user_email"
        case userName = "user_name"
        case userId = "user_id"
        case projectId = "project_id"
        case attachmentUrls = "attachment_urls"
    }
}

/// A request to add a message to an existing support ticket.
///
/// ## Discussion
/// Use this structure when adding a new message to a support ticket conversation.
///
/// ## Example
/// ```swift
/// let request = CreateMessageRequest(
///     ticketId: "ticket123",
///     content: "Here's more information about the issue.",
///     authorName: "John Doe",
///     authorEmail: "john@example.com",
///     attachmentUrls: nil
/// )
/// ```
public struct CreateMessageRequest: Encodable, Sendable {
    /// The ID of the ticket to add the message to.
    public let ticketId: String
    
    /// The text content of the message.
    public let content: String
    
    /// The display name of the message author.
    public let authorName: String?
    
    /// The email address of the message author.
    public let authorEmail: String?
    
    /// URLs of files to attach to the message.
    public let attachmentUrls: [String]?

    public init(
        ticketId: String,
        content: String,
        authorName: String?,
        authorEmail: String?,
        attachmentUrls: [String]?
    ) {
        self.ticketId = ticketId
        self.content = content
        self.authorName = authorName
        self.authorEmail = authorEmail
        self.attachmentUrls = attachmentUrls
    }

    enum CodingKeys: String, CodingKey {
        case content
        case ticketId = "ticket_id"
        case authorName = "author_name"
        case authorEmail = "author_email"
        case attachmentUrls = "attachment_urls"
    }
}

/// Filters for querying support tickets.
///
/// ## Discussion
/// Use this structure to filter support tickets when fetching them from the API.
///
/// ## Example
/// ```swift
/// let filters = SupportRequestFilters(
///     email: "user@example.com",
///     externalUserId: "user123",
///     page: 1,
///     perPage: 20
/// )
/// ```
public struct SupportRequestFilters: Sendable {
    /// Filter by user email address.
    public let email: String?

    /// Filter by external user ID.
    public let externalUserId: String?

    /// The page number for pagination (1-based).
    public let page: Int

    /// The number of tickets to return per page.
    public let perPage: Int

    public init(
        email: String? = nil,
        externalUserId: String? = nil,
        page: Int = 1,
        perPage: Int = 20
    ) {
        self.email = email
        self.externalUserId = externalUserId
        self.page = page
        self.perPage = perPage
    }
}

// MARK: - Magic Link Types

/// Response from sending a magic link email.
///
/// ## Discussion
/// This response is returned when a magic link is sent to a user's email
/// for accessing their support tickets without authentication.
public struct MagicLinkResponse: Decodable, Sendable {
    /// Whether the magic link was sent successfully.
    public let success: Bool

    /// A message describing the result.
    public let message: String
}

/// Response from verifying a magic link token.
///
/// ## Discussion
/// This response contains the user's tickets after successfully verifying
/// a magic link token.
public struct MagicLinkVerifyResponse: Decodable, Sendable {
    /// The user's support tickets.
    public let tickets: [SupportTicket]

    /// The verified user's email address.
    public let userEmail: String

    enum CodingKeys: String, CodingKey {
        case tickets
        case userEmail = "user_email"
    }
}

/// Request to send a magic link.
internal struct MagicLinkRequest: Encodable, Sendable {
    let projectId: String
    let userEmail: String

    enum CodingKeys: String, CodingKey {
        case projectId = "project_id"
        case userEmail = "user_email"
    }
}

/// Request to add a message using a magic link token.
internal struct AddMessageWithTokenRequest: Encodable, Sendable {
    let content: String
}
