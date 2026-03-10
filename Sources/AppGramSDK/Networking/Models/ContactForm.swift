import Foundation

/// Represents a contact form that can be displayed to users.
///
/// ## Discussion
/// Contact forms allow users to submit information through customizable fields.
/// Forms can have various field types (text, email, select, etc.) and can be
/// configured with validation rules and submission settings.
///
/// ## Example
/// ```swift
/// let form = ContactForm(
///     id: "form123",
///     name: "Contact Us",
///     slug: "contact-us",
///     description: "Get in touch with us",
///     projectId: "project456",
///     fields: [field1, field2],
///     submitButtonText: "Submit",
///     successMessage: "Thank you!",
///     emailRecipient: "support@example.com",
///     emailSubject: "New Contact Form Submission",
///     isActive: true,
///     enabled: true,
///     createdAt: Date()
/// )
/// ```
public struct ContactForm: Codable, Identifiable, Sendable {
    /// The unique identifier for the form.
    public let id: String
    
    /// The display name of the form.
    public let name: String
    
    /// The URL-friendly slug identifier.
    public let slug: String?
    
    /// An optional description of the form.
    public let description: String?
    
    /// The project ID this form belongs to.
    public let projectId: String?
    
    /// The list of fields in the form.
    public let fields: [FormField]
    
    /// The text to display on the submit button.
    public let submitButtonText: String
    
    /// The message to display after successful submission.
    public let successMessage: String?
    
    /// The email address to send form submissions to.
    public let emailRecipient: String?
    
    /// The subject line for email notifications.
    public let emailSubject: String?
    
    /// Whether the form is active.
    public let isActive: Bool?
    
    /// Whether the form is enabled.
    public let enabled: Bool?
    
    /// The date when the form was created.
    public let createdAt: Date?

    public init(
        id: String,
        name: String,
        slug: String?,
        description: String?,
        projectId: String?,
        fields: [FormField],
        submitButtonText: String,
        successMessage: String?,
        emailRecipient: String?,
        emailSubject: String?,
        isActive: Bool?,
        enabled: Bool?,
        createdAt: Date?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.projectId = projectId
        self.fields = fields
        self.submitButtonText = submitButtonText
        self.successMessage = successMessage
        self.emailRecipient = emailRecipient
        self.emailSubject = emailSubject
        self.isActive = isActive
        self.enabled = enabled
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, fields
        case projectId = "project_id"
        case submitButtonText = "submit_button_text"
        case successMessage = "success_message"
        case emailRecipient = "email_recipient"
        case emailSubject = "email_subject"
        case isActive = "is_active"
        case enabled
        case createdAt = "created_at"
    }
    
    /// Computed property to check if form is active (uses enabled if isActive is not set)
    public var isFormActive: Bool {
        return enabled ?? isActive ?? true
    }
}

/// Represents a single field in a contact form.
///
/// ## Discussion
/// Form fields define the input elements in a contact form, including their
/// type, label, validation rules, and display options.
///
/// ## Example
/// ```swift
/// let field = FormField(
///     id: "field1",
///     type: .email,
///     label: "Email Address",
///     placeholder: "Enter your email",
///     required: true,
///     options: nil,
///     defaultValue: nil,
///     validation: nil,
///     order: 1
/// )
/// ```
public struct FormField: Codable, Identifiable, Sendable {
    /// The unique identifier for the field.
    public let id: String
    
    /// The type of input field.
    public let type: FieldType
    
    /// The label text to display for the field.
    public let label: String
    
    /// The placeholder text to show when the field is empty.
    public let placeholder: String?
    
    /// Whether this field is required.
    public let required: Bool
    
    /// The available options for select, radio, or checkbox fields.
    public let options: [String]?
    
    /// The default value for the field.
    public let defaultValue: String?
    
    /// Validation rules for the field.
    public let validation: FieldValidation?
    
    /// The display order of the field.
    public let order: Int?

    public init(
        id: String,
        type: FieldType,
        label: String,
        placeholder: String?,
        required: Bool,
        options: [String]?,
        defaultValue: String?,
        validation: FieldValidation?,
        order: Int?
    ) {
        self.id = id
        self.type = type
        self.label = label
        self.placeholder = placeholder
        self.required = required
        self.options = options
        self.defaultValue = defaultValue
        self.validation = validation
        self.order = order
    }

    enum CodingKeys: String, CodingKey {
        case id, type, label, placeholder, required, options, validation, order
        case defaultValue = "default"
    }
}

/// Types of input fields available in contact forms.
///
/// ## Discussion
/// Defines the different input field types that can be used in forms.
///
/// ## Example
/// ```swift
/// let fieldType: FieldType = .email
/// ```
public enum FieldType: String, Codable, Sendable {
    /// A single-line text input field.
    case text = "text"
    
    /// An email input field with email validation.
    case email = "email"
    
    /// A multi-line text area input field.
    case textarea = "textarea"
    
    /// A dropdown select field.
    case select = "select"
    
    /// A radio button group (single selection).
    case radio = "radio"
    
    /// A checkbox field (multiple selections possible).
    case checkbox = "checkbox"

    public var displayName: String {
        switch self {
        case .text:
            return "Text"
        case .email:
            return "Email"
        case .textarea:
            return "Text Area"
        case .select:
            return "Select"
        case .radio:
            return "Radio"
        case .checkbox:
            return "Checkbox"
        }
    }
}

/// Validation rules for a form field.
///
/// ## Discussion
/// Defines validation constraints that are applied to form field input,
/// such as minimum/maximum length and pattern matching.
///
/// ## Example
/// ```swift
/// let validation = FieldValidation(
///     minLength: 3,
///     maxLength: 50,
///     pattern: "^[a-zA-Z]+$",
///     patternMessage: "Only letters allowed"
/// )
/// ```
public struct FieldValidation: Codable, Sendable {
    /// The minimum required length of the input.
    public let minLength: Int?
    
    /// The maximum allowed length of the input.
    public let maxLength: Int?
    
    /// A regular expression pattern to validate against.
    public let pattern: String?
    
    /// The error message to display if the pattern doesn't match.
    public let patternMessage: String?

    public init(
        minLength: Int?,
        maxLength: Int?,
        pattern: String?,
        patternMessage: String?
    ) {
        self.minLength = minLength
        self.maxLength = maxLength
        self.pattern = pattern
        self.patternMessage = patternMessage
    }

    enum CodingKeys: String, CodingKey {
        case minLength = "min_length"
        case maxLength = "max_length"
        case pattern
        case patternMessage = "pattern_message"
    }
}

/// A submission of a contact form.
///
/// ## Discussion
/// Use this structure when submitting form data to the API. The data dictionary
/// maps field IDs to their submitted values.
///
/// ## Example
/// ```swift
/// let submission = ContactFormSubmission(
///     formId: "form123",
///     data: ["field1": "John Doe", "field2": "john@example.com"]
/// )
/// ```
public struct ContactFormSubmission: Encodable, Sendable {
    /// The ID of the form being submitted.
    public let formId: String
    
    /// A dictionary mapping field IDs to their submitted values.
    public let data: [String: String]

    public init(
        formId: String,
        data: [String: String]
    ) {
        self.formId = formId
        self.data = data
    }

    enum CodingKeys: String, CodingKey {
        case formId = "form_id"
        case data
    }
}

// Response model for contact forms endpoint (returns dictionary of forms)
public struct ContactFormsResponse: Decodable, Sendable {
    public let contactForms: [String: ContactForm]

    enum CodingKeys: String, CodingKey {
        case contactForms = "contact_forms"
    }
}

// Response wrapper for contact forms endpoint
public struct ContactFormsAPIResponse: Decodable, Sendable {
    public let success: Bool?
    public let data: ContactFormsResponse

    enum CodingKeys: String, CodingKey {
        case success, data
    }
}

// Response model for contact form detail endpoint
// GET /api/v1/projects/{projectId}/contact-forms/{formId}
internal struct ContactFormDetailData: Decodable, Sendable {
    public let contactForm: ContactForm
    public let recentSubmissions: [ContactFormSubmissionDetail]?
    public let submissionCount: Int?

    enum CodingKeys: String, CodingKey {
        case contactForm = "contact_form"
        case recentSubmissions = "recent_submissions"
        case submissionCount = "submission_count"
    }
}

// Detail model for form submission (read-only, for display)
internal struct ContactFormSubmissionDetail: Decodable, Sendable {
    public let id: String
    public let formId: String
    public let projectId: String
    public let data: [String: String]
    public let ipAddress: String?
    public let userAgent: String?
    public let submittedAt: Date
    public let processedAt: Date?
    public let emailSent: Bool?

    enum CodingKeys: String, CodingKey {
        case id
        case formId = "form_id"
        case projectId = "project_id"
        case data
        case ipAddress = "ip_address"
        case userAgent = "user_agent"
        case submittedAt = "submitted_at"
        case processedAt = "processed_at"
        case emailSent = "email_sent"
    }
}

// Response model for standalone form endpoint
public struct StandaloneFormResponse: Decodable, Sendable {
    public let form: ContactForm
    public let projectId: String
    public let branding: Branding?

    enum CodingKeys: String, CodingKey {
        case form
        case projectId = "project_id"
        case branding
    }
}

public struct Branding: Decodable, Sendable {
    public let primaryColor: String?
    public let logo: String?
    public let name: String?

    enum CodingKeys: String, CodingKey {
        case primaryColor = "primary_color"
        case logo
        case name
    }
}
