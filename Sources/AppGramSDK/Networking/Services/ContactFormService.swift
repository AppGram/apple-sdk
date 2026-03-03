import Foundation

/// Protocol for interacting with contact form functionality.
///
/// ## Discussion
/// The contact form service provides methods to load contact form configurations
/// and submit form data.
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getContactFormService()
/// let form = try await service.getForm(formId: "contact-us")
/// ```
public protocol ContactFormServiceProtocol: Sendable {
    func getForm(formId: String) async throws -> ContactForm
    func getFormDirect(projectId: String, formId: String) async throws -> ContactForm
    func getStandaloneForm(formId: String) async throws -> StandaloneFormResponse
    func submitForm(_ submission: ContactFormSubmission, projectId: String?) async throws
    func trackFormView(formId: String) async throws
}

internal actor ContactFormService: ContactFormServiceProtocol {
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

    /// Get a contact form using the direct endpoint
    /// GET /api/v1/projects/{projectId}/contact-forms/{formId}
    public func getForm(formId: String) async throws -> ContactForm {
        logDebug("Getting contact form with id: \(formId) from project: \(projectId)")
        let response: APIResponse<ContactFormDetailData> = try await apiClient.get(
            endpoint: .contactForm(projectId: projectId, formId: formId)
        )
        logDebug("Fetched contact form: \(response.data.contactForm.name)")
        return response.data.contactForm
    }

    /// Get a contact form directly using the project-specific endpoint
    /// GET /api/v1/projects/{projectId}/contact-forms/{formId}
    public func getFormDirect(projectId: String, formId: String) async throws -> ContactForm {
        logDebug("Getting contact form directly with id: \(formId) from project: \(projectId)")
        let response: APIResponse<ContactFormDetailData> = try await apiClient.get(
            endpoint: .contactForm(projectId: projectId, formId: formId)
        )
        logDebug("Fetched contact form directly: \(response.data.contactForm.name)")
        return response.data.contactForm
    }

    /// Get a standalone contact form using the public form endpoint
    /// Returns form, projectId, and branding information
    public func getStandaloneForm(formId: String) async throws -> StandaloneFormResponse {
        logDebug("Getting standalone contact form with id: \(formId)")
        let response: StandaloneFormResponse = try await apiClient.get(
            endpoint: .standaloneForm(formId: formId)
        )
        logDebug("Fetched standalone contact form: formId=\(response.form.id), projectId=\(response.projectId)")
        return response
    }

    public func submitForm(_ submission: ContactFormSubmission, projectId: String? = nil) async throws {
        let effectiveProjectId = projectId ?? self.projectId
        logInfo("Submitting contact form: \(submission.formId) to project: \(effectiveProjectId)")
        try await apiClient.post(
            endpoint: .submitContactForm(projectId: effectiveProjectId, formId: submission.formId),
            body: submission
        )
        logInfo("Successfully submitted contact form")
    }

    /// Track a form view for analytics.
    ///
    /// Call this method when a form is displayed to track view analytics.
    ///
    /// - Parameter formId: The ID of the form being viewed.
    public func trackFormView(formId: String) async throws {
        logDebug("Tracking form view for formId: \(formId)")
        try await apiClient.post(
            endpoint: .trackFormView(projectId: projectId, formId: formId),
            body: EmptyBody()
        )
        logInfo("Successfully tracked form view for: \(formId)")
    }
}

/// Empty body for POST requests that don't require a body.
private struct EmptyBody: Encodable {}

internal struct FormValidator {
    public init() {}

    public func validate(value: String, field: FormField) -> String? {
        if field.required && value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "\(field.label) is required"
        }

        guard !value.isEmpty else { return nil }

        if field.type == .email {
            if !isValidEmail(value) {
                return "Please enter a valid email address"
            }
        }

        if let validation = field.validation {
            if let minLength = validation.minLength, value.count < minLength {
                return "\(field.label) must be at least \(minLength) characters"
            }

            if let maxLength = validation.maxLength, value.count > maxLength {
                return "\(field.label) must be at most \(maxLength) characters"
            }

            if let pattern = validation.pattern {
                if !matchesPattern(value, pattern: pattern) {
                    return validation.patternMessage ?? "\(field.label) is invalid"
                }
            }
        }

        return nil
    }

    private func isValidEmail(_ email: String) -> Bool {
        let emailPattern = "^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$"
        return matchesPattern(email, pattern: emailPattern)
    }

    private func matchesPattern(_ value: String, pattern: String) -> Bool {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: []) else {
            return false
        }
        let range = NSRange(value.startIndex..., in: value)
        return regex.firstMatch(in: value, options: [], range: range) != nil
    }
}
