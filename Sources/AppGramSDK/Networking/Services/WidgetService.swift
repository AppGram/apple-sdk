import Foundation

/// Protocol for interacting with widget-related functionality.
///
/// ## Discussion
/// The widget service provides methods to fetch widget data and content
/// for different widget types (feedback, roadmap, status, etc.).
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getWidgetService()
/// let widgetData = try await service.getWidgetData(type: .feedback)
/// ```
public protocol WidgetServiceProtocol: Sendable {
    /// Fetches widget data for the specified widget type.
    /// - Parameter type: The type of widget data to fetch.
    /// - Returns: Widget data dictionary with content.
    func getWidgetData(type: AGWidgetConfiguration.WidgetType, parameters: [String: String]) async throws -> [String: Any]
}

internal actor WidgetService: WidgetServiceProtocol {
    private let apiClient: APIClient
    private let projectId: String
    private let userContextProvider: @Sendable () -> UserContext?
    
    public init(
        apiClient: APIClient,
        projectId: String,
        userContextProvider: @escaping @Sendable () -> UserContext?
    ) {
        self.apiClient = apiClient
        self.projectId = projectId
        self.userContextProvider = userContextProvider
    }
    
    public func getWidgetData(type: AGWidgetConfiguration.WidgetType, parameters: [String: String]) async throws -> [String: Any] {
        logDebug("Getting widget data for type: \(type.rawValue)")
        
        // For now, return empty data structure
        // In the future, this can fetch actual widget data from the API
        var widgetData: [String: Any] = [
            "type": type.rawValue,
            "projectId": projectId
        ]
        
        // Add parameters
        for (key, value) in parameters {
            widgetData[key] = value
        }
        
        // Add user context if available
        if let userContext = userContextProvider() {
            var userData: [String: Any?] = [:]
            userData["userId"] = userContext.userId
            userData["email"] = userContext.email
            userData["name"] = userContext.name
            widgetData["user"] = userData
        }
        
        return widgetData
    }
}
