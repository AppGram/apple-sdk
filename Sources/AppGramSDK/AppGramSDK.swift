import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

/// The main entry point for the AppGram SDK.
///
/// Use `AppGramSDK.shared` to access the singleton instance and configure the SDK
/// with your project credentials. The SDK provides access to various services including
/// feedback, roadmap, support, surveys, help center, contact forms, status pages, and releases.
///
/// ## Configuration
///
/// Before using any SDK features, you must configure the SDK:
///
/// ```swift
/// AppGramSDK.shared.configure(
///     projectId: "your-project-id",
///     apiKey: "your-api-key",
///     announcementConfiguration: AnnouncementConfiguration(
///         orgSlug: "your-org",
///         projectSlug: "your-project"
///     )
/// )
/// ```
///
/// ## User Context
///
/// Optionally set user information to personalize the experience:
///
/// ```swift
/// AppGramSDK.shared.setUser(
///     userId: "user123",
///     email: "user@example.com",
///     name: "John Doe"
/// )
/// ```
public final class AppGramSDK: @unchecked Sendable {
    /// The shared singleton instance of the AppGram SDK.
    ///
    /// Use this instance to configure and access all SDK functionality.
    public static let shared = AppGramSDK()
    
    /// The current version of the AppGram SDK.
    ///
    /// The version string follows semantic versioning (e.g., "1.2.0").
    public static let version = "1.2.0"

    private let lock = NSLock()
    private var _configuration: Configuration?
    private var _userContext: UserContext = .anonymous
    private var apiClient: APIClient?
    private var feedbackService: FeedbackService?
    private var roadmapService: RoadmapService?
    private var supportService: SupportService?
    private var surveyService: SurveyService?
    private var helpService: HelpService?
    private var contactFormService: ContactFormService?
    private var statusService: StatusService?
    private var releasesService: ReleasesService?
    private var widgetService: WidgetService?
    private var blogService: BlogService?
    private var notificationManager: NotificationManager?
    private var popupManager: PopupManager?
    private var announcementManager: AnnouncementManager?
    private var lifecycleObserver: AppLifecycleObserver?

    /// The current configuration of the SDK.
    ///
    /// Returns `nil` if the SDK has not been configured yet. Use ``configure(projectId:baseURL:theme:)``
    /// to set the configuration.
    ///
    /// - Returns: The current configuration, or `nil` if not configured.
    public var configuration: Configuration? {
        lock.lock()
        defer { lock.unlock() }
        return _configuration
    }

    /// The current user context.
    ///
    /// Returns the user information that has been set via ``setUser(userId:email:name:)``.
    /// If no user has been set, returns an anonymous user context.
    ///
    /// - Returns: The current user context.
    public var userContext: UserContext {
        lock.lock()
        defer { lock.unlock() }
        return _userContext
    }

    private init() {}

    // MARK: - Configuration

    /// Configures the AppGram SDK with the provided project credentials and settings.
    ///
    /// This method must be called before using any SDK features. It initializes all
    /// internal services and prepares the SDK for use.
    ///
    /// - Parameters:
    ///   - projectId: Your unique project identifier from AppGram.
    ///   - baseURL: The base URL for the AppGram API. Defaults to `"https://api.appgram.dev"`.
    ///   - theme: An optional custom theme to apply to all SDK views. If `nil`, the default theme is used.
    ///   - apiKey: An optional API key for authenticating requests to the AppGram API. If provided, it will be included in the X-API-Key header of all HTTP requests.
    ///   - popupConfiguration: An optional configuration for the popup system.
    ///   - announcementConfiguration: An optional configuration for the announcement system.
    ///
    /// ## Example
    ///
    /// ```swift
    /// AppGramSDK.shared.configure(
    ///     projectId: "your-project-id",
    ///     baseURL: "https://api.appgram.dev",
    ///     theme: .default,
    ///     apiKey: "your-api-key",
    ///     announcementConfiguration: .init(
    ///         orgSlug: "my-org",
    ///         projectSlug: "my-project"
    ///     )
    /// )
    /// ```
    @MainActor
    public func configure(
        projectId: String,
        baseURL: String = "https://api.appgram.dev",
        theme: AppGramTheme? = nil,
        apiKey: String? = nil,
        popupConfiguration: PopupConfiguration? = nil,
        announcementConfiguration: AnnouncementConfiguration? = nil
    ) {
        // Preserve existing API key if new one is not provided
        let finalApiKey: String?
        lock.lock()
        if let apiKey = apiKey {
            finalApiKey = apiKey
        } else if let existingConfig = self._configuration {
            finalApiKey = existingConfig.apiKey
        } else {
            finalApiKey = nil
        }
        lock.unlock()
        
        // Mask API key for logging (show first 8 chars and last 4 chars)
        let maskedApiKey: String
        if let apiKey = finalApiKey, apiKey.count > 12 {
            let start = String(apiKey.prefix(8))
            let end = String(apiKey.suffix(4))
            maskedApiKey = "\(start)****\(end)"
        } else if let apiKey = finalApiKey {
            maskedApiKey = String(repeating: "*", count: min(apiKey.count, 12))
        } else {
            maskedApiKey = "nil"
        }
        
        logInfo("========================================")
        logInfo("AppGramSDK Configuration:")
        logInfo("  Project ID: \(projectId)")
        logInfo("  Base URL: \(baseURL)")
        logInfo("  API Key: \(maskedApiKey) \(finalApiKey != nil ? "(provided)" : "(not provided)")")
        logInfo("  Theme: \(theme != nil ? "custom" : "default")")
        logInfo("  Popup Configuration: \(popupConfiguration != nil ? "enabled" : "disabled")")
        logInfo("  Announcement Configuration: \(announcementConfiguration != nil ? "enabled" : "disabled")")
        logInfo("========================================")

        lock.lock()
        self._configuration = Configuration(
            projectId: projectId,
            baseURL: baseURL,
            theme: theme ?? (self._configuration?.theme ?? .default),
            apiKey: finalApiKey
        )
        lock.unlock()

        self.apiClient = APIClient(baseURL: baseURL, projectId: projectId, apiKey: finalApiKey)

        logDebug("APIClient initialized successfully")

        let userContextProvider: @Sendable () -> UserContext? = { [weak self] in
            self?.userContext
        }

        self.feedbackService = FeedbackService(
            apiClient: apiClient!,
            projectId: projectId,
            userContextProvider: userContextProvider
        )

        self.roadmapService = RoadmapService(
            apiClient: apiClient!,
            projectId: projectId
        )

        self.supportService = SupportService(
            apiClient: apiClient!,
            projectId: projectId,
            userContextProvider: userContextProvider
        )

        self.surveyService = SurveyService(
            apiClient: apiClient!,
            projectId: projectId,
            userContextProvider: userContextProvider
        )

        self.helpService = HelpService(
            apiClient: apiClient!,
            projectId: projectId
        )

        self.contactFormService = ContactFormService(
            apiClient: apiClient!,
            projectId: projectId,
            userContextProvider: userContextProvider
        )

        self.statusService = StatusService(apiClient: apiClient!)
        self.releasesService = ReleasesService(apiClient: apiClient!)

        self.widgetService = WidgetService(
            apiClient: apiClient!,
            projectId: projectId,
            userContextProvider: userContextProvider
        )

        self.blogService = BlogService(
            apiClient: apiClient!,
            projectId: projectId
        )

        self.notificationManager = NotificationManager()

        // Initialize popup system if configuration provided
        if let popupConfig = popupConfiguration {
            let tracker = PopupTracker()
            self.popupManager = PopupManager(
                configuration: popupConfig,
                tracker: tracker,
                projectId: projectId,
                surveyService: surveyService,
                feedbackService: feedbackService
            )

            #if canImport(UIKit) || canImport(AppKit)
            self.lifecycleObserver = AppLifecycleObserver()

            // Setup lifecycle hooks
            lifecycleObserver?.onLaunch = { [weak self] in
                Task { @MainActor in
                    await self?.popupManager?.checkAndPresentIfNeeded()
                }
            }

            lifecycleObserver?.onForeground = { [weak self] in
                Task { @MainActor in
                    await self?.popupManager?.checkAndPresentIfNeeded()
                }
            }
            #endif

            // Start popup system
            popupManager?.start()

            logInfo("PopupManager initialized and started")
        }

        // Initialize announcement system if configuration provided
        if let announcementConfig = announcementConfiguration {
            self.announcementManager = AnnouncementManager(
                configuration: announcementConfig,
                releasesService: releasesService!
            )

            // Setup lifecycle hooks for announcements if not already created
            if lifecycleObserver == nil {
                #if canImport(UIKit) || canImport(AppKit)
                self.lifecycleObserver = AppLifecycleObserver()
                #endif
            }

            #if canImport(UIKit) || canImport(AppKit)
            // Add announcement check to launch hook
            let existingOnLaunch = lifecycleObserver?.onLaunch
            lifecycleObserver?.onLaunch = { [weak self] in
                existingOnLaunch?()
                Task { @MainActor in
                    await self?.announcementManager?.checkAndPresentIfNeeded()
                }
            }
            #endif

            // Start announcement system
            announcementManager?.start()

            logInfo("AnnouncementManager initialized and started")
        }
    }

    // MARK: - User Context

    /// Sets the current user context for the SDK.
    ///
    /// Use this method to identify the current user, which enables personalized features
    /// and user-specific data across all SDK services.
    ///
    /// - Parameters:
    ///   - userId: An optional unique identifier for the user.
    ///   - email: An optional email address for the user.
    ///   - name: An optional display name for the user.
    ///
    /// ## Example
    ///
    /// ```swift
    /// AppGramSDK.shared.setUser(
    ///     userId: "user123",
    ///     email: "user@example.com",
    ///     name: "John Doe"
    /// )
    /// ```
    ///
    /// - Note: All parameters are optional. You can provide any combination of them.
    public func setUser(userId: String?, email: String?, name: String?) {
        logDebug("Setting user context - userId: \(userId ?? "nil"), email: \(email ?? "nil"), name: \(name ?? "nil")")

        lock.lock()
        defer { lock.unlock() }
        self._userContext = UserContext(
            userId: userId,
            email: email,
            name: name,
            isAnonymous: false
        )
    }

    /// Clears the current user context and sets it back to anonymous.
    ///
    /// After calling this method, the SDK will treat the user as anonymous until
    /// ``setUser(userId:email:name:)`` is called again.
    ///
    /// ## Example
    ///
    /// ```swift
    /// AppGramSDK.shared.clearUser()
    /// ```
    public func clearUser() {
        logDebug("Clearing user context")

        lock.lock()
        defer { lock.unlock() }
        self._userContext = .anonymous
    }

    // MARK: - Services

    /// Returns the feedback service instance.
    ///
    /// Use this service to interact with feedback-related functionality, such as
    /// submitting feedback, viewing feedback lists, and managing feedback items.
    ///
    /// - Returns: A ``FeedbackServiceProtocol`` instance for managing feedback.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let feedbackService = try AppGramSDK.shared.getFeedbackService()
    /// ```
    public func getFeedbackService() throws -> FeedbackServiceProtocol {
        guard let service = feedbackService else {
            logError("FeedbackService not configured. Call configure() first.")
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the roadmap service instance.
    ///
    /// Use this service to interact with roadmap functionality, such as viewing
    /// feature roadmaps and tracking planned features.
    ///
    /// - Returns: A ``RoadmapServiceProtocol`` instance for managing roadmaps.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let roadmapService = try AppGramSDK.shared.getRoadmapService()
    /// ```
    public func getRoadmapService() throws -> RoadmapServiceProtocol {
        guard let service = roadmapService else {
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the support service instance.
    ///
    /// Use this service to interact with support ticket functionality, such as
    /// creating tickets, viewing ticket lists, and managing support interactions.
    ///
    /// - Returns: A ``SupportServiceProtocol`` instance for managing support tickets.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let supportService = try AppGramSDK.shared.getSupportService()
    /// ```
    public func getSupportService() throws -> SupportServiceProtocol {
        guard let service = supportService else {
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the survey service instance.
    ///
    /// Use this service to interact with survey functionality, such as loading
    /// and submitting survey responses.
    ///
    /// - Returns: A ``SurveyServiceProtocol`` instance for managing surveys.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let surveyService = try AppGramSDK.shared.getSurveyService()
    /// ```
    public func getSurveyService() throws -> SurveyServiceProtocol {
        guard let service = surveyService else {
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the help service instance.
    ///
    /// Use this service to interact with help center functionality, such as
    /// loading help articles and documentation.
    ///
    /// - Returns: A ``HelpServiceProtocol`` instance for managing help content.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let helpService = try AppGramSDK.shared.getHelpService()
    /// ```
    public func getHelpService() throws -> HelpServiceProtocol {
        guard let service = helpService else {
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the contact form service instance.
    ///
    /// Use this service to interact with contact form functionality, such as
    /// loading form configurations and submitting form data.
    ///
    /// - Returns: A ``ContactFormServiceProtocol`` instance for managing contact forms.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let contactFormService = try AppGramSDK.shared.getContactFormService()
    /// ```
    public func getContactFormService() throws -> ContactFormServiceProtocol {
        guard let service = contactFormService else {
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the status service instance.
    ///
    /// Use this service to interact with status page functionality, such as
    /// loading status information and incident data.
    ///
    /// - Returns: A ``StatusServiceProtocol`` instance for managing status pages.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let statusService = try AppGramSDK.shared.getStatusService()
    /// ```
    public func getStatusService() throws -> StatusServiceProtocol {
        guard let service = statusService else {
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the releases service instance.
    ///
    /// Use this service to interact with releases functionality, such as
    /// loading release notes and version information.
    ///
    /// - Returns: A ``ReleasesServiceProtocol`` instance for managing releases.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let releasesService = try AppGramSDK.shared.getReleasesService()
    /// ```
    public func getReleasesService() throws -> ReleasesServiceProtocol {
        guard let service = releasesService else {
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the widget service instance.
    ///
    /// Use this service to interact with widget functionality, such as
    /// creating customizable widgets for feedback, roadmap, status, or custom content.
    ///
    /// - Returns: A ``WidgetServiceProtocol`` instance for managing widgets.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let widgetService = try AppGramSDK.shared.getWidgetService()
    /// ```
    public func getWidgetService() throws -> WidgetServiceProtocol {
        guard let service = widgetService else {
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the blog service instance.
    ///
    /// Use this service to interact with blog functionality, such as fetching
    /// blog posts, categories, and searching content.
    ///
    /// - Returns: A ``BlogServiceProtocol`` implementation for interacting with the blog API.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let service = try AppGramSDK.shared.getBlogService()
    /// let posts = try await service.getBlogPosts()
    /// ```
    public func getBlogService() throws -> BlogServiceProtocol {
        guard let service = blogService else {
            logError("BlogService not configured. Call configure() first.")
            throw AppGramError.notConfigured
        }
        return service
    }

    /// Returns the notification manager instance.
    ///
    /// Use this manager to handle push notifications and in-app notifications
    /// for status updates and other SDK-related events.
    ///
    /// - Returns: A ``NotificationManager`` instance for managing notifications.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let notificationManager = try AppGramSDK.shared.getNotificationManager()
    /// ```
    public func getNotificationManager() throws -> NotificationManager {
        guard let manager = notificationManager else {
            throw AppGramError.notConfigured
        }
        return manager
    }

    /// Returns the popup manager instance.
    ///
    /// Use this manager to manually trigger popups, check status, or control the popup system.
    ///
    /// - Returns: A ``PopupManager`` instance for managing popups.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured with popup support.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let popupManager = try AppGramSDK.shared.getPopupManager()
    /// popupManager.showPopupManually()
    /// ```
    public func getPopupManager() throws -> PopupManager {
        guard let manager = popupManager else {
            throw AppGramError.notConfigured
        }
        return manager
    }

    /// Returns the announcement manager instance.
    ///
    /// Use this manager to manually trigger announcements, clear seen history, or control the announcement system.
    ///
    /// - Returns: An ``AnnouncementManager`` instance for managing announcements.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured with announcement support.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let announcementManager = try AppGramSDK.shared.getAnnouncementManager()
    /// await announcementManager.presentAnnouncements()
    /// ```
    public func getAnnouncementManager() throws -> AnnouncementManager {
        guard let manager = announcementManager else {
            throw AppGramError.notConfigured
        }
        return manager
    }

    /// Manually presents announcements to the user.
    ///
    /// This is a convenience method to show announcements without needing to get the manager.
    /// Useful for "What's New" buttons or manual announcement triggers.
    ///
    /// ## Example
    ///
    /// ```swift
    /// Button("What's New") {
    ///     Task { @MainActor in
    ///         await AppGramSDK.shared.showAnnouncements()
    ///     }
    /// }
    /// ```
    @MainActor
    public func showAnnouncements() async {
        guard let manager = announcementManager else {
            logWarning("AnnouncementManager not configured. Make sure to provide announcementConfiguration when calling configure().")
            return
        }
        await manager.presentAnnouncements()
    }

    // MARK: - SwiftUI Views

    /// Returns a SwiftUI view for displaying and managing feedback.
    ///
    /// This view provides a complete interface for users to view existing feedback
    /// and submit new feedback items. The view is automatically themed according
    /// to the SDK configuration.
    ///
    /// - Returns: A SwiftUI view for feedback management.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             try AppGramSDK.shared.feedbackView()
    ///         }
    ///     }
    /// }
    /// ```
    public func feedbackView() throws -> some View {
        let service = try getFeedbackService()
        return FeedbackListView(feedbackService: service)
            .appGramTheme(configuration?.theme ?? .default)
    }

    /// Returns a SwiftUI view for displaying the product roadmap.
    ///
    /// This view shows planned features, their status, and progress. The view
    /// is automatically themed according to the SDK configuration.
    ///
    /// - Returns: A SwiftUI view for the roadmap.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct RoadmapView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             try AppGramSDK.shared.roadmapView()
    ///         }
    ///     }
    /// }
    /// ```
    public func roadmapView() throws -> some View {
        let service = try getRoadmapService()
        return RoadmapView(roadmapService: service)
            .appGramTheme(configuration?.theme ?? .default)
    }

    /// Returns a SwiftUI view for displaying and managing support tickets.
    ///
    /// This view provides a complete interface for users to view their support
    /// tickets, create new tickets, and manage existing ones. The view is
    /// automatically themed according to the SDK configuration.
    ///
    /// - Returns: A SwiftUI view for support ticket management.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct SupportView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             try AppGramSDK.shared.supportView()
    ///         }
    ///     }
    /// }
    /// ```
    public func supportView() throws -> some View {
        let service = try getSupportService()
        let userContextProvider: @Sendable () -> UserContext? = { [weak self] in
            self?.userContext
        }
        return SupportTicketListView(supportService: service, userContextProvider: userContextProvider)
            .appGramTheme(configuration?.theme ?? .default)
    }

    /// Returns a SwiftUI view for displaying and submitting a specific support form.
    ///
    /// This view loads and displays a specific support form identified by its ID,
    /// allowing users to fill out and submit the form directly without selecting
    /// from a list of forms.
    ///
    /// - Parameter formId: The unique identifier of the support form to display.
    /// - Returns: A SwiftUI view for the support form.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct SupportFormView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             try AppGramSDK.shared.supportFormView(formId: "support_123")
    ///         }
    ///     }
    /// }
    /// ```
    public func supportFormView(formId: String) throws -> some View {
        let service = try getSupportService()
        let userContextProvider: @Sendable () -> UserContext? = { [weak self] in
            self?.userContext
        }
        return SupportFormSelectionView(
            supportService: service,
            userContextProvider: userContextProvider,
            formId: formId
        ) {
            // Dismiss handler - can be customized if needed
        }
        .appGramTheme(configuration?.theme ?? .default)
    }

    /// Returns a SwiftUI view for displaying and submitting a survey.
    ///
    /// This view loads and displays a survey identified by its slug, allowing
    /// users to view questions and submit responses. The view is automatically
    /// themed according to the SDK configuration.
    ///
    /// - Parameters:
    ///   - slug: The unique identifier (slug) of the survey to display.
    ///   - style: The visual style of the survey. Defaults to ``SurveyStyle/normal``.
    /// - Returns: A SwiftUI view for the survey.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct SurveyView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             try AppGramSDK.shared.surveyView(
    ///                 slug: "user-satisfaction-survey",
    ///                 style: .normal
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    public func surveyView(slug: String, style: SurveyStyle = .normal) throws -> some View {
        guard let config = configuration else {
            throw AppGramError.notConfigured
        }
        let service = try getSurveyService()
        let userContextProvider: @Sendable () -> UserContext? = { [weak self] in
            self?.userContext
        }
        return SurveyView(
            slug: slug,
            surveyService: service,
            projectId: config.projectId,
            userContextProvider: userContextProvider,
            style: style
        )
        .appGramTheme(config.theme)
    }

    /// Returns a SwiftUI view for displaying the help center.
    ///
    /// This view provides access to help articles, documentation, and support
    /// resources. The view is automatically themed according to the SDK configuration.
    ///
    /// - Parameter configuration: Configuration options for customizing the help center appearance and behavior. Defaults to ``HelpCenterConfiguration/default``.
    /// - Returns: A SwiftUI view for the help center.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct HelpCenterView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             try AppGramSDK.shared.helpCenterView(
    ///                 configuration: .init(
    ///                     decisionTreeButtonColor: .blue,
    ///                     articleDisplayBehavior: .pushToStack
    ///                 )
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    public func helpCenterView(
        configuration: HelpCenterConfiguration = .default
    ) throws -> some View {
        let service = try getHelpService()
        return HelpCenterView(
            helpService: service,
            configuration: configuration
        )
        .appGramTheme(self.configuration?.theme ?? .default)
    }

    /// Returns a SwiftUI view for displaying and submitting a contact form.
    ///
    /// This view loads and displays a contact form identified by its form ID,
    /// allowing users to fill out and submit the form. The view is automatically
    /// themed according to the SDK configuration.
    ///
    /// - Parameter formId: The unique identifier of the contact form to display.
    /// - Returns: A SwiftUI view for the contact form.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct ContactFormView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             try AppGramSDK.shared.contactFormView(formId: "contact-us")
    ///         }
    ///     }
    /// }
    /// ```
    public func contactFormView(formId: String) throws -> some View {
        guard let config = configuration else {
            throw AppGramError.notConfigured
        }
        let service = try getContactFormService()
        let userContextProvider: @Sendable () -> UserContext? = { [weak self] in
            self?.userContext
        }
        return ContactFormView(
            formId: formId,
            contactFormService: service,
            projectId: config.projectId,
            userContextProvider: userContextProvider
        )
        .appGramTheme(config.theme)
    }

    /// Returns a SwiftUI view for displaying a status page.
    ///
    /// This view shows the current status of services, recent incidents, and
    /// maintenance schedules. The view is automatically themed according to
    /// the SDK configuration.
    ///
    /// - Parameters:
    ///   - slug: The unique identifier (slug) of the status page. Defaults to `"status"`.
    ///   - configuration: Configuration options for customizing the status page appearance and behavior. Defaults to ``StatusConfiguration/default``.
    /// - Returns: A SwiftUI view for the status page.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct StatusPageView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             try AppGramSDK.shared.statusPageView(
    ///                 slug: "status",
    ///                 configuration: .default
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    public func statusPageView(
        slug: String = "status",
        configuration: StatusConfiguration = .default,
        onSubscribeCallback: (() -> Void)? = nil
    ) throws -> some View {
        guard let config = self.configuration else {
            throw AppGramError.notConfigured
        }
        return StatusPageView(
            projectId: config.projectId,
            slug: slug,
            apiBaseURL: config.baseURL,
            apiKey: config.apiKey,
            configuration: configuration,
            notificationManager: notificationManager,
            onSubscribe: onSubscribeCallback
        )
        .appGramTheme(config.theme)
    }

    /// Returns a SwiftUI view for displaying release notes.
    ///
    /// This view shows release notes, version history, and changelog information
    /// for a specific organization and project. The view is automatically themed
    /// according to the SDK configuration.
    ///
    /// - Parameters:
    ///   - orgSlug: The unique identifier (slug) of the organization.
    ///   - projectSlug: The unique identifier (slug) of the project.
    ///   - configuration: Configuration options for customizing the releases view appearance and behavior. Defaults to ``ReleasesConfiguration/default``.
    /// - Returns: A SwiftUI view for displaying releases.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct ReleasesView: View {
    ///     var body: some View {
    ///         NavigationView {
    ///             try AppGramSDK.shared.releasesView(
    ///                 orgSlug: "my-org",
    ///                 projectSlug: "my-project",
    ///                 configuration: .default
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    public func releasesView(
        orgSlug: String,
        projectSlug: String,
        configuration: ReleasesConfiguration = .default
    ) throws -> some View {
        guard let config = self.configuration else {
            throw AppGramError.notConfigured
        }
        return ReleasesListView(
            orgSlug: orgSlug,
            projectSlug: projectSlug,
            apiBaseURL: config.baseURL,
            apiKey: config.apiKey,
            configuration: configuration,
            notificationManager: notificationManager
        )
        .appGramTheme(config.theme)
    }

    /// Returns a SwiftUI view for displaying a customizable widget.
    ///
    /// This view provides a flexible, fully customizable widget that can be embedded
    /// in any screen. The widget can display feedback, roadmap, status, or custom content
    /// with extensive customization options including styles, sizes, colors, and CTA buttons.
    ///
    /// - Parameter configuration: Configuration options for customizing the widget's appearance and behavior.
    /// - Returns: A SwiftUI view for the widget.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct MyView: View {
    ///     var body: some View {
    ///         VStack {
    ///             try AppGramSDK.shared.widgetView(
    ///                 configuration: .feedback(
    ///                     style: .card,
    ///                     size: .medium,
    ///                     ctaButton: .init(title: "Submit Feedback"),
    ///                     ctaAction: {
    ///                         // Handle CTA tap
    ///                     }
    ///                 )
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    public func widgetView(configuration: AGWidgetConfiguration) throws -> some View {
        guard let config = self.configuration else {
            throw AppGramError.notConfigured
        }
        let service = try getWidgetService()
        return WidgetView(
            configuration: configuration,
            widgetService: service
        )
        .appGramTheme(config.theme)
    }

    /// Returns a SwiftUI view for displaying blog posts and content.
    ///
    /// This view shows a list of blog posts with search, filtering, and pagination.
    /// Users can tap posts to view full content.
    ///
    /// - Returns: A SwiftUI view for the blog.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let blogView = try AppGramSDK.shared.blogView()
    /// ```
    public func blogView() throws -> some View {
        guard let config = self.configuration else {
            throw AppGramError.notConfigured
        }
        let service = try getBlogService()
        return BlogView(blogService: service)
            .appGramTheme(config.theme)
    }

    // MARK: - UIKit Integration

    #if canImport(UIKit)
    /// Returns a UIKit view controller for displaying and managing feedback.
    ///
    /// This method wraps the SwiftUI feedback view in a `UIHostingController`,
    /// making it suitable for use in UIKit-based applications.
    ///
    /// - Returns: A `UIViewController` containing the feedback view.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let feedbackVC = try AppGramSDK.feedbackViewController()
    /// navigationController?.pushViewController(feedbackVC, animated: true)
    /// ```
    public static func feedbackViewController() throws -> UIViewController {
        let view = try shared.feedbackView()
        return UIHostingController(rootView: AnyView(view))
    }

    /// Returns a UIKit view controller for displaying the product roadmap.
    ///
    /// This method wraps the SwiftUI roadmap view in a `UIHostingController`,
    /// making it suitable for use in UIKit-based applications.
    ///
    /// - Returns: A `UIViewController` containing the roadmap view.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let roadmapVC = try AppGramSDK.roadmapViewController()
    /// navigationController?.pushViewController(roadmapVC, animated: true)
    /// ```
    public static func roadmapViewController() throws -> UIViewController {
        let view = try shared.roadmapView()
        return UIHostingController(rootView: AnyView(view))
    }

    /// Returns a UIKit view controller for displaying and managing support tickets.
    ///
    /// This method wraps the SwiftUI support view in a `UIHostingController`,
    /// making it suitable for use in UIKit-based applications.
    ///
    /// - Returns: A `UIViewController` containing the support view.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let supportVC = try AppGramSDK.supportViewController()
    /// navigationController?.pushViewController(supportVC, animated: true)
    /// ```
    public static func supportViewController() throws -> UIViewController {
        let view = try shared.supportView()
        return UIHostingController(rootView: AnyView(view))
    }

    /// Returns a UIKit view controller for displaying and submitting a survey.
    ///
    /// This method wraps the SwiftUI survey view in a `UIHostingController`,
    /// making it suitable for use in UIKit-based applications.
    ///
    /// - Parameter slug: The unique identifier (slug) of the survey to display.
    /// - Returns: A `UIViewController` containing the survey view.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let surveyVC = try AppGramSDK.surveyViewController(slug: "user-satisfaction-survey")
    /// navigationController?.pushViewController(surveyVC, animated: true)
    /// ```
    public static func surveyViewController(slug: String) throws -> UIViewController {
        let view = try shared.surveyView(slug: slug)
        return UIHostingController(rootView: AnyView(view))
    }

    /// Returns a UIKit view controller for displaying the help center.
    ///
    /// This method wraps the SwiftUI help center view in a `UIHostingController`,
    /// making it suitable for use in UIKit-based applications.
    ///
    /// - Returns: A `UIViewController` containing the help center view.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let helpCenterVC = try AppGramSDK.helpCenterViewController()
    /// navigationController?.pushViewController(helpCenterVC, animated: true)
    /// ```
    public static func helpCenterViewController() throws -> UIViewController {
        let view = try shared.helpCenterView()
        return UIHostingController(rootView: AnyView(view))
    }

    /// Returns a UIKit view controller for displaying and submitting a contact form.
    ///
    /// This method wraps the SwiftUI contact form view in a `UIHostingController`,
    /// making it suitable for use in UIKit-based applications.
    ///
    /// - Parameter formId: The unique identifier of the contact form to display.
    /// - Returns: A `UIViewController` containing the contact form view.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let contactFormVC = try AppGramSDK.contactFormViewController(formId: "contact-us")
    /// navigationController?.pushViewController(contactFormVC, animated: true)
    /// ```
    public static func contactFormViewController(formId: String) throws -> UIViewController {
        let view = try shared.contactFormView(formId: formId)
        return UIHostingController(rootView: AnyView(view))
    }

    /// Returns a UIKit view controller for displaying a status page.
    ///
    /// This method wraps the SwiftUI status page view in a `UIHostingController`,
    /// making it suitable for use in UIKit-based applications.
    ///
    /// - Parameters:
    ///   - slug: The unique identifier (slug) of the status page. Defaults to `"status"`.
    ///   - configuration: Configuration options for customizing the status page appearance and behavior. Defaults to ``StatusConfiguration/default``.
    /// - Returns: A `UIViewController` containing the status page view.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let statusPageVC = try AppGramSDK.statusPageViewController(
    ///     slug: "status",
    ///     configuration: .default
    /// )
    /// navigationController?.pushViewController(statusPageVC, animated: true)
    /// ```
    public static func statusPageViewController(
        slug: String = "status",
        configuration: StatusConfiguration = .default
    ) throws -> UIViewController {
        let view = try shared.statusPageView(slug: slug, configuration: configuration)
        return UIHostingController(rootView: AnyView(view))
    }

    /// Returns a UIKit view controller for displaying release notes.
    ///
    /// This method wraps the SwiftUI releases view in a `UIHostingController`,
    /// making it suitable for use in UIKit-based applications.
    ///
    /// - Parameters:
    ///   - orgSlug: The unique identifier (slug) of the organization.
    ///   - projectSlug: The unique identifier (slug) of the project.
    ///   - configuration: Configuration options for customizing the releases view appearance and behavior. Defaults to ``ReleasesConfiguration/default``.
    /// - Returns: A `UIViewController` containing the releases view.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let releasesVC = try AppGramSDK.releasesViewController(
    ///     orgSlug: "my-org",
    ///     projectSlug: "my-project",
    ///     configuration: .default
    /// )
    /// navigationController?.pushViewController(releasesVC, animated: true)
    /// ```
    public static func releasesViewController(
        orgSlug: String,
        projectSlug: String,
        configuration: ReleasesConfiguration = .default
    ) throws -> UIViewController {
        let view = try shared.releasesView(
            orgSlug: orgSlug,
            projectSlug: projectSlug,
            configuration: configuration
        )
        return UIHostingController(rootView: AnyView(view))
    }

    /// Returns a UIKit view controller for displaying a customizable widget.
    ///
    /// This method wraps the SwiftUI widget view in a `UIHostingController`,
    /// making it suitable for use in UIKit-based applications.
    ///
    /// - Parameter configuration: Configuration options for customizing the widget's appearance and behavior.
    /// - Returns: A `UIViewController` containing the widget view.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let widgetVC = try AppGramSDK.widgetViewController(
    ///     configuration: .feedback(
    ///         style: .card,
    ///         size: .medium
    ///     )
    /// )
    /// view.addSubview(widgetVC.view)
    /// ```
    public static func widgetViewController(
        configuration: AGWidgetConfiguration
    ) throws -> UIViewController {
        let view = try shared.widgetView(configuration: configuration)
        return UIHostingController(rootView: AnyView(view))
    }
    #endif
}

// MARK: - Convenience Extensions

extension View {
    /// Applies the AppGram theme configuration to the view.
    ///
    /// This convenience method applies the theme from the SDK's current configuration
    /// to any SwiftUI view. If the SDK is not configured, it uses the default theme.
    ///
    /// - Returns: A view with the AppGram theme applied.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct MyView: View {
    ///     var body: some View {
    ///         Text("Hello, World!")
    ///             .configuredForAppGram()
    ///     }
    /// }
    /// ```
    public func configuredForAppGram() -> some View {
        self.appGramTheme(AppGramSDK.shared.configuration?.theme ?? .default)
    }
}

// MARK: - Widget Convenience Extensions

extension AppGramSDK {
    /// Creates a widget view with a feedback configuration.
    ///
    /// This convenience method creates a widget configured for feedback with sensible defaults.
    ///
    /// - Parameters:
    ///   - style: The visual style of the widget. Defaults to `.card`.
    ///   - size: The size of the widget. Defaults to `.medium`.
    ///   - ctaTitle: The title for the CTA button. Defaults to "Submit Feedback".
    ///   - ctaAction: Optional action to perform when the CTA button is tapped.
    /// - Returns: A SwiftUI view for the feedback widget.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    ///
    /// ## Example
    ///
    /// ```swift
    /// struct ContentView: View {
    ///     var body: some View {
    ///         VStack {
    ///             try AppGramSDK.shared.feedbackWidget(
    ///                 style: .card,
    ///                 size: .medium,
    ///                 ctaAction: {
    ///                     // Handle feedback submission
    ///                 }
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    public func feedbackWidget(
        style: AGWidgetConfiguration.WidgetStyle = .card,
        size: AGWidgetConfiguration.WidgetSize = .medium,
        ctaTitle: String = "Submit Feedback",
        ctaAction: (() -> Void)? = nil
    ) throws -> some View {
        try widgetView(configuration: .feedback(
            style: style,
            size: size,
            ctaButton: .init(title: ctaTitle),
            ctaAction: ctaAction
        ))
    }
    
    /// Creates a widget view with a roadmap configuration.
    ///
    /// This convenience method creates a widget configured for roadmap with sensible defaults.
    ///
    /// - Parameters:
    ///   - style: The visual style of the widget. Defaults to `.card`.
    ///   - size: The size of the widget. Defaults to `.medium`.
    ///   - ctaTitle: The title for the CTA button. Defaults to "View Roadmap".
    ///   - ctaAction: Optional action to perform when the CTA button is tapped.
    /// - Returns: A SwiftUI view for the roadmap widget.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    public func roadmapWidget(
        style: AGWidgetConfiguration.WidgetStyle = .card,
        size: AGWidgetConfiguration.WidgetSize = .medium,
        ctaTitle: String = "View Roadmap",
        ctaAction: (() -> Void)? = nil
    ) throws -> some View {
        try widgetView(configuration: .roadmap(
            style: style,
            size: size,
            ctaButton: .init(title: ctaTitle),
            ctaAction: ctaAction
        ))
    }
    
    /// Creates a widget view with a status configuration.
    ///
    /// This convenience method creates a widget configured for status with sensible defaults.
    ///
    /// - Parameters:
    ///   - style: The visual style of the widget. Defaults to `.card`.
    ///   - size: The size of the widget. Defaults to `.medium`.
    ///   - slug: The status page slug. Defaults to "status".
    ///   - ctaTitle: The title for the CTA button. Defaults to "View Status".
    ///   - ctaAction: Optional action to perform when the CTA button is tapped.
    /// - Returns: A SwiftUI view for the status widget.
    /// - Throws: ``AppGramError/notConfigured`` if the SDK has not been configured.
    public func statusWidget(
        style: AGWidgetConfiguration.WidgetStyle = .card,
        size: AGWidgetConfiguration.WidgetSize = .medium,
        slug: String = "status",
        ctaTitle: String = "View Status",
        ctaAction: (() -> Void)? = nil
    ) throws -> some View {
        try widgetView(configuration: .status(
            style: style,
            size: size,
            ctaButton: .init(title: ctaTitle),
            ctaAction: ctaAction,
            slug: slug
        ))
    }
}
