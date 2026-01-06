import Foundation

/// Represents a vote on a feedback item (wish).
///
/// ## Discussion
/// Votes allow users to express support for a wish. Each user can vote once per wish.
/// For anonymous users, votes are tracked using device fingerprints.
///
/// ## Example
/// ```swift
/// let vote = Vote(
///     id: "vote123",
///     wishId: "wish456",
///     userId: "user789",
///     fingerprint: nil,
///     createdAt: Date()
/// )
/// ```
public struct Vote: Codable, Identifiable, Sendable {
    /// The unique identifier for the vote.
    public let id: String
    
    /// The ID of the wish this vote is for.
    public let wishId: String
    
    /// The user ID of the voter, if authenticated.
    public let userId: String?
    
    /// The device fingerprint for anonymous voters.
    public let fingerprint: String?
    
    /// The date when the vote was created.
    public let createdAt: Date

    public init(
        id: String,
        wishId: String,
        userId: String?,
        fingerprint: String?,
        createdAt: Date
    ) {
        self.id = id
        self.wishId = wishId
        self.userId = userId
        self.fingerprint = fingerprint
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case wishId = "wish_id"
        case userId = "user_id"
        case fingerprint
        case createdAt = "created_at"
    }
}

/// A request to add a vote to a wish.
///
/// ## Discussion
/// Use this structure when submitting a vote to the API.
///
/// ## Example
/// ```swift
/// let request = VoteRequest(
///     wishId: "wish123",
///     projectId: "project456",
///     userId: "user789",
///     fingerprint: nil
/// )
/// ```
public struct VoteRequest: Encodable, Sendable {
    /// The ID of the wish to vote for.
    public let wishId: String
    
    /// The project ID.
    public let projectId: String
    
    /// The optional user ID of the voter.
    public let userId: String?
    
    /// The device fingerprint for anonymous voters.
    public let fingerprint: String?

    public init(
        wishId: String,
        projectId: String,
        userId: String?,
        fingerprint: String?
    ) {
        self.wishId = wishId
        self.projectId = projectId
        self.userId = userId
        self.fingerprint = fingerprint
    }

    enum CodingKeys: String, CodingKey {
        case wishId = "wish_id"
        case projectId = "project_id"
        case userId = "user_id"
        case fingerprint
    }
}
