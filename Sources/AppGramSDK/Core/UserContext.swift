import Foundation

/// Represents the current user's context within the AppGram SDK.
///
/// ## Discussion
/// User context is used to personalize the SDK experience and associate user actions
/// with specific users. If no user information is provided, the SDK uses an anonymous
/// user context.
///
/// ## Example
/// ```swift
/// let context = UserContext(
///     userId: "user123",
///     email: "user@example.com",
///     name: "John Doe",
///     isAnonymous: false
/// )
/// ```
public struct UserContext: Sendable {
    /// An optional unique identifier for the user.
    public let userId: String?
    
    /// An optional email address for the user.
    public let email: String?
    
    /// An optional display name for the user.
    public let name: String?
    
    /// Whether this context represents an anonymous user.
    public let isAnonymous: Bool

    public init(userId: String?, email: String?, name: String?, isAnonymous: Bool) {
        self.userId = userId
        self.email = email
        self.name = name
        self.isAnonymous = isAnonymous
    }

    /// A pre-configured anonymous user context.
    ///
    /// Use this when no user information is available or when the user has logged out.
    ///
    /// ## Example
    /// ```swift
    /// let anonymousUser = UserContext.anonymous
    /// ```
    public static var anonymous: UserContext {
        UserContext(userId: nil, email: nil, name: nil, isAnonymous: true)
    }
}
