import Foundation

/// Configuration settings for the AppGram SDK.
///
/// ## Discussion
/// Contains the essential settings needed to connect to the AppGram API and customize
/// the SDK's appearance. This configuration is typically set when calling
/// ``AppGramSDK/configure(projectId:baseURL:theme:apiKey:)``.
///
/// ## Example
/// ```swift
/// let config = Configuration(
///     projectId: "your-project-id",
///     baseURL: "https://api.appgram.dev",
///     theme: .default,
///     apiKey: "your-api-key"
/// )
/// ```
public struct Configuration: Sendable {
    /// The unique identifier for your AppGram project.
    public let projectId: String
    
    /// The base URL for the AppGram API.
    public let baseURL: String
    
    /// The theme to apply to all SDK views.
    public let theme: AppGramTheme
    
    /// The API key for authenticating requests to the AppGram API.
    ///
    /// This key is used to authenticate all API requests. If provided, it will be
    /// included in the `X-API-Key` header of all HTTP requests.
    public let apiKey: String?

    public init(
        projectId: String,
        baseURL: String = "https://api.appgram.com",
        theme: AppGramTheme = .default,
        apiKey: String? = nil
    ) {
        self.projectId = projectId
        self.baseURL = baseURL
        self.theme = theme
        self.apiKey = apiKey
    }
}
