// DOCUMENTATION TEMPLATE
// Copy these examples and adapt them to your types

// ==========================================
// EXAMPLE 1: Type Documentation (Survey)
// ==========================================

/// Represents a survey that can be presented to users.
///
/// Use this struct to display surveys fetched from your AppGram project.
/// Surveys contain multiple nodes representing different question types
/// and support branching logic for dynamic user experiences.
///
/// ## Discussion
///
/// The Survey struct provides a structured representation of your AppGram
/// surveys. Each survey has a unique slug that identifies it in your project
/// and contains a tree of nodes that define the questions and flow.
///
/// Surveys are typically fetched using the `SurveyServiceProtocol` and then
/// displayed using `SurveyView`. The SDK handles all the presentation logic,
/// response collection, and submission automatically.
///
/// ## Example
///
/// ```swift
/// // Fetch a survey
/// let service = try AppGramSDK.shared.getSurveyService()
/// let survey = try await service.getSurvey(slug: "customer-satisfaction")
///
/// // Display it
/// SurveyView(slug: "customer-satisfaction")
/// ```
///
/// - Note: Surveys require network connectivity to fetch
/// - Important: Always handle errors when fetching surveys
public struct Survey: Codable, Identifiable {

    /// The unique identifier for this survey
    public let id: String

    /// The URL-friendly slug used to fetch this survey
    ///
    /// This is the same slug you configured in your AppGram dashboard.
    /// Use this to fetch the survey via the API.
    public let slug: String

    /// The human-readable title displayed to users
    ///
    /// This appears at the top of the survey view and should clearly
    /// describe the survey's purpose.
    public let title: String

    /// The first node in the survey flow
    ///
    /// This is the starting point for the survey. Use this to begin
    /// rendering the question tree.
    public let rootNode: SurveyNode

    /// Visual styling configuration for this survey
    ///
    /// Controls colors, fonts, and layout. If not provided, uses
    /// the default AppGram theme.
    public let style: SurveyStyle?
}

// ==========================================
// EXAMPLE 2: Method Documentation
// ==========================================

extension SurveyService {

    /// Fetches a survey by its slug from the AppGram API.
    ///
    /// This method retrieves the complete survey structure including all
    /// nodes, branching logic, and styling information.
    ///
    /// - Parameter slug: The URL-friendly identifier for the survey
    /// - Returns: A fully populated Survey instance
    /// - Throws: `AppGramError.notConfigured` if the SDK hasn't been configured
    /// - Throws: `AppGramError.networkError` if the request fails
    /// - Throws: `AppGramError.notFound` if the survey doesn't exist
    ///
    /// ## Discussion
    ///
    /// The survey data is fetched from your AppGram project and cached
    /// locally for 5 minutes to improve performance. Subsequent calls
    /// within the cache window will return the cached data.
    ///
    /// This method requires an active network connection. If offline,
    /// it will attempt to return cached data if available.
    ///
    /// ## Example
    ///
    /// ```swift
    /// do {
    ///     let service = try AppGramSDK.shared.getSurveyService()
    ///     let survey = try await service.getSurvey(slug: "nps-2024")
    ///
    ///     print("Loaded: \(survey.title)")
    ///     print("Questions: \(survey.rootNode.children.count)")
    /// } catch AppGramError.notFound {
    ///     print("Survey not found in your project")
    /// } catch {
    ///     print("Error: \(error.localizedDescription)")
    /// }
    /// ```
    public func getSurvey(slug: String) async throws -> Survey {
        // Implementation...
    }
}

// ==========================================
// EXAMPLE 3: Protocol Documentation
// ==========================================

/// Provides access to survey functionality.
///
/// Use this protocol to fetch surveys, submit responses, and manage
/// survey-related operations.
///
/// ## Discussion
///
/// The SurveyServiceProtocol is the main interface for working with
/// surveys in your app. Get an instance using:
///
/// ```swift
/// let service = try AppGramSDK.shared.getSurveyService()
/// ```
///
/// All methods are async and may throw errors. Always handle errors
/// appropriately and provide feedback to users when operations fail.
///
/// ## Topics
///
/// ### Fetching Surveys
///
/// - ``getSurvey(slug:)``
/// - ``listSurveys()``
///
/// ### Submitting Responses
///
/// - ``submitResponse(_:)``
///
/// ## Example
///
/// ```swift
/// // Get the service
/// let service = try AppGramSDK.shared.getSurveyService()
///
/// // Fetch a survey
/// let survey = try await service.getSurvey(slug: "feedback")
///
/// // Submit a response
/// let response = SurveyResponse(...)
/// try await service.submitResponse(response)
/// ```
public protocol SurveyServiceProtocol {

    /// Fetches a survey by its slug.
    ///
    /// - Parameter slug: The survey identifier
    /// - Returns: The requested survey
    /// - Throws: An error if fetching fails
    func getSurvey(slug: String) async throws -> Survey
}

// ==========================================
// EXAMPLE 4: Enum Documentation
// ==========================================

/// Visual styles available for surveys.
///
/// Use these predefined styles to customize the appearance of surveys
/// in your app. Each style defines colors, fonts, and spacing.
///
/// ## Example
///
/// ```swift
/// SurveyView(slug: "feedback", style: .minimal)
/// ```
public enum SurveyStyle: String, Codable {

    /// Default AppGram styling with brand colors
    ///
    /// This style uses your project's configured colors from the
    /// AppGram dashboard.
    case `default`

    /// Clean, minimal design with subtle colors
    ///
    /// Best for professional contexts where you want the survey to
    /// blend seamlessly with your app's design.
    case minimal

    /// Bold, colorful design for maximum engagement
    ///
    /// Uses bright colors and larger text to draw attention.
    /// Ideal for in-app surveys where you want high completion rates.
    case vibrant
}

// ==========================================
// EXAMPLE 5: Property Documentation
// ==========================================

public struct Configuration {

    /// Your AppGram project ID
    ///
    /// Get this from your AppGram dashboard under Settings → API.
    /// This is required to connect the SDK to your project.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let config = Configuration(
    ///     projectId: "proj_abc123",
    ///     baseURL: "https://api.appgram.com"
    /// )
    /// ```
    public let projectId: String

    /// The base URL for API requests
    ///
    /// Defaults to `https://api.appgram.com`. Only change this if you're
    /// using a custom AppGram deployment or testing against a staging
    /// environment.
    ///
    /// - Note: Must include the protocol (https://)
    /// - Important: Do not include a trailing slash
    public let baseURL: String

    /// Custom theme for SDK views
    ///
    /// Provide your own colors, fonts, and styling to match your app's
    /// design. If not provided, uses AppGram's default theme.
    ///
    /// See ``AppGramTheme`` for available customization options.
    public let theme: AppGramTheme?
}

// ==========================================
// TIPS
// ==========================================

/*

1. START WITH THE ABSTRACT
   - First line should be a clear, concise summary
   - Should make sense when read alone
   - End with a period

2. ADD DISCUSSION FOR COMPLEX TYPES
   - Explain when and how to use this type
   - Describe common patterns
   - Mention related types

3. ALWAYS INCLUDE EXAMPLES
   - Show real, copy-pasteable code
   - Cover common use cases
   - Include error handling

4. DOCUMENT PARAMETERS AND RETURNS
   - Be specific about what each parameter does
   - Describe the return value format
   - List all possible errors

5. USE CALLOUTS APPROPRIATELY
   - Note: Additional information
   - Important: Critical information users must know
   - Warning: Potential problems or gotchas

6. CROSS-REFERENCE RELATED SYMBOLS
   - Use ``SymbolName`` to link to other types
   - Helps users discover related functionality

7. KEEP IT UP TO DATE
   - Update docs when changing behavior
   - Remove docs for deprecated features
   - Add docs for new features

*/
