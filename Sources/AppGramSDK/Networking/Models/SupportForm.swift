import Foundation

/// Represents a support form that can be displayed to users.
///
/// ## Discussion
/// Support forms allow users to submit support requests through customizable fields.
/// Forms can have various field types (text, email, select, radio, textarea, etc.) and can be
/// configured with validation rules and submission settings.
///
/// ## Example
/// ```swift
/// let form = SupportForm(
///     id: "support_123",
///     name: "Technical Support Form",
///     description: "Submit technical issues with detailed information",
///     fields: [field1, field2],
///     submitButtonText: "Submit Request",
///     successMessage: "Your support request has been submitted!",
///     enabled: true,
///     createdAt: Date()
/// )
/// ```
public struct SupportForm: Codable, Identifiable, Hashable, Sendable {
    /// The unique identifier for the form.
    public let id: String
    
    /// The display name of the form.
    public let name: String
    
    /// An optional description of the form.
    public let description: String?
    
    /// The list of fields in the form.
    public let fields: [FormField]
    
    /// The text to display on the submit button.
    public let submitButtonText: String
    
    /// The message to display after successful submission.
    public let successMessage: String?
    
    /// Whether the form is enabled.
    public let enabled: Bool?
    
    /// The date when the form was created.
    public let createdAt: Date?
    
    /// The date when the form was last updated.
    public let updatedAt: Date?

    public init(
        id: String,
        name: String,
        description: String?,
        fields: [FormField],
        submitButtonText: String,
        successMessage: String?,
        enabled: Bool?,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.fields = fields
        self.submitButtonText = submitButtonText
        self.successMessage = successMessage
        self.enabled = enabled
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, name, description, fields
        case submitButtonText = "submit_button_text"
        case successMessage = "success_message"
        case enabled
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    /// Computed property to check if form is active
    public var isFormActive: Bool {
        return enabled ?? true
    }

    /// Creates a default support form for use when API forms are unavailable
    public static func createDefault() -> SupportForm {
        let emailField = FormField(
            id: "user_email",
            type: .email,
            label: "Your Email",
            placeholder: "Enter your email address",
            required: true,
            options: nil,
            defaultValue: nil,
            validation: nil,
            order: 1
        )

        return SupportForm(
            id: "default_support_form",
            name: "General Support",
            description: "Submit a support request and we'll get back to you as soon as possible.",
            fields: [emailField],
            submitButtonText: "Submit Request",
            successMessage: "Your support request has been submitted successfully. We'll get back to you soon.",
            enabled: true,
            createdAt: nil,
            updatedAt: nil
        )
    }

    // MARK: - Hashable Conformance
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: SupportForm, rhs: SupportForm) -> Bool {
        lhs.id == rhs.id
    }
}

/// A submission of a support form.
///
/// ## Discussion
/// Use this structure when submitting form data to the API. The data dictionary
/// maps field IDs to their submitted values. The subject and description are required
/// fields that are separate from the form field data.
///
/// ## Example
/// ```swift
/// let submission = SupportFormSubmission(
///     formId: "support_123",
///     subject: "Application crash on login",
///     description: "The application crashes when I try to log in",
///     data: ["issue_type": "Bug", "severity": "High"],
///     userEmail: "user@example.com",
///     userName: "John Doe"
/// )
/// ```
public struct SupportFormSubmission: Encodable, Sendable {
    /// The ID of the form being submitted.
    public let formId: String
    
    /// The subject of the support request.
    public let subject: String
    
    /// The description of the support request.
    public let description: String
    
    /// A dictionary mapping field IDs to their submitted values.
    public let data: [String: String]
    
    /// The user's email address.
    public let userEmail: String?
    
    /// The user's name.
    public let userName: String?

    public init(
        formId: String,
        subject: String,
        description: String,
        data: [String: String],
        userEmail: String?,
        userName: String?
    ) {
        self.formId = formId
        self.subject = subject
        self.description = description
        self.data = data
        self.userEmail = userEmail
        self.userName = userName
    }

    enum CodingKeys: String, CodingKey {
        case formId = "form_id"
        case subject
        case description
        case data
        case userEmail = "user_email"
        case userName = "user_name"
    }
}

// Response model for support forms endpoint (returns dictionary of forms)
public struct SupportFormsResponse: Decodable, Sendable {
    public let supportForms: [String: SupportForm]

    enum CodingKeys: String, CodingKey {
        case supportForms = "support_forms"
    }
}

// Response wrapper for support forms endpoint
public struct SupportFormsAPIResponse: Decodable, Sendable {
    public let success: Bool?
    public let data: SupportFormsResponse

    enum CodingKeys: String, CodingKey {
        case success, data
    }
}

// Response model for support form detail endpoint
// GET /api/v1/projects/{projectId}/support-forms/{formId}
internal struct SupportFormDetailData: Decodable, Sendable {
    public let supportForm: SupportForm

    enum CodingKeys: String, CodingKey {
        case supportForm = "support_form"
    }
}

