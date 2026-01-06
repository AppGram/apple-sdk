import Foundation
import SwiftUI

@MainActor
@Observable
internal final class ContactFormViewModel {
    public private(set) var form: ContactForm?
    public private(set) var isLoading = false
    public private(set) var isSubmitting = false
    public private(set) var isSubmitted = false
    public private(set) var error: AppGramError?
    public private(set) var fieldErrors: [String: String] = [:]

    public var answers: [String: String] = [:]

    private let contactFormService: ContactFormServiceProtocol
    private let projectId: String
    private let userContextProvider: @Sendable () -> UserContext?
    private let validator = FormValidator()
    private let rateLimiter = RateLimiter()
    private let sanitizer = InputSanitizer()
    private var effectiveProjectId: String?

    public init(
        contactFormService: ContactFormServiceProtocol,
        projectId: String,
        userContextProvider: @escaping @Sendable () -> UserContext?
    ) {
        self.contactFormService = contactFormService
        self.projectId = projectId
        self.userContextProvider = userContextProvider
        self.effectiveProjectId = projectId
    }

    public func loadForm(formId: String, useStandaloneEndpoint: Bool = false) async {
        logDebug("ContactFormViewModel: Loading form with id: \(formId), standalone: \(useStandaloneEndpoint)")
        isLoading = true
        error = nil

        do {
            let loadedForm: ContactForm
            if useStandaloneEndpoint {
                // Use standalone endpoint which returns form, projectId, and branding
                let response = try await contactFormService.getStandaloneForm(formId: formId)
                loadedForm = response.form
                effectiveProjectId = response.projectId
                logDebug("ContactFormViewModel: Loaded standalone form, projectId: \(response.projectId)")
            } else {
                // Try embedded form endpoint first
                do {
                    loadedForm = try await contactFormService.getForm(formId: formId)
                    effectiveProjectId = projectId
                } catch let err as AppGramError {
                    // If project-specific endpoint returns 404, fallback to standalone endpoint
                    if case .notFound = err {
                        logDebug("ContactFormViewModel: Project-specific form not found, trying standalone endpoint")
                        do {
                            let response = try await contactFormService.getStandaloneForm(formId: formId)
                            loadedForm = response.form
                            effectiveProjectId = response.projectId
                            logDebug("ContactFormViewModel: Loaded form via standalone endpoint fallback, projectId: \(response.projectId)")
                        } catch {
                            // If standalone also fails, rethrow the original error
                            throw err
                        }
                    } else {
                        // For other errors, rethrow
                        throw err
                    }
                }
            }
            
            form = loadedForm

            for field in loadedForm.fields {
                if field.type == .checkbox {
                    answers[field.id] = "false"
                } else {
                    answers[field.id] = ""
                }
            }
            logInfo("ContactFormViewModel: Loaded form '\(loadedForm.name)' with \(loadedForm.fields.count) fields")
        } catch let err as AppGramError {
            logError("ContactFormViewModel: Failed to load form - \(err.localizedDescription)")
            // Handle specific error cases
            if case .notFound = err {
                error = .notFound
            } else if case .forbidden = err {
                error = .validationError("This form is not available")
            } else if case .unauthorized = err {
                error = .validationError("This form is not available")
            } else {
                error = err
            }
        } catch {
            logError("ContactFormViewModel: Network error loading form - \(error.localizedDescription)")
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public func validateField(_ fieldId: String) {
        guard let form = form,
              let field = form.fields.first(where: { $0.id == fieldId }),
              let value = answers[fieldId] else {
            return
        }

        if let errorMessage = validator.validate(value: value, field: field) {
            fieldErrors[fieldId] = errorMessage
        } else {
            fieldErrors.removeValue(forKey: fieldId)
        }
    }

    public func validateAllFields() -> Bool {
        guard let form = form else { return false }

        logDebug("ContactFormViewModel: Validating all fields")
        fieldErrors = [:]
        var isValid = true

        for field in form.fields {
            let value = answers[field.id] ?? ""
            if let errorMessage = validator.validate(value: value, field: field) {
                fieldErrors[field.id] = errorMessage
                isValid = false
            }
        }

        if !isValid {
            logWarning("ContactFormViewModel: Validation failed with \(fieldErrors.count) errors")
        }

        return isValid
    }

    public var isValid: Bool {
        guard let form = form else { return false }

        for field in form.fields {
            let value = answers[field.id] ?? ""
            if validator.validate(value: value, field: field) != nil {
                return false
            }
        }

        return true
    }

    public func submit() async -> Bool {
        guard validateAllFields() else {
            error = .validationError("Please fix the errors above")
            return false
        }

        guard let form = form else {
            error = .notConfigured
            return false
        }

        // Check rate limiting
        let canSubmit = await rateLimiter.canSubmit(formId: form.id)
        if !canSubmit {
            let remaining = await rateLimiter.remainingSubmissions(formId: form.id)
            error = .validationError("Rate limit exceeded. Please try again later. (Max 10 submissions per hour)")
            logWarning("ContactFormViewModel: Rate limit exceeded for form \(form.id), remaining: \(remaining)")
            return false
        }

        isSubmitting = true
        error = nil

        // Sanitize input data
        let sanitizedData = sanitizer.sanitize(answers)

        // Create submission with new format: { form_id, data: { field-id: value } }
        let submission = ContactFormSubmission(
            formId: form.id,
            data: sanitizedData
        )

        do {
            // Use effective project ID (from standalone form response if available)
            let effectiveProjectId = self.effectiveProjectId ?? projectId
            
            try await contactFormService.submitForm(submission, projectId: effectiveProjectId)
            
            // Record successful submission for rate limiting
            await rateLimiter.recordSubmission(formId: form.id)
            
            isSubmitted = true
            isSubmitting = false
            return true
        } catch let err as AppGramError {
            error = err
            isSubmitting = false
            return false
        } catch {
            self.error = .networkError(error.localizedDescription)
            isSubmitting = false
            return false
        }
    }

    public func clearError() {
        error = nil
    }

    public func reset() {
        answers = [:]
        fieldErrors = [:]
        isSubmitted = false
        error = nil

        if let form = form {
            for field in form.fields {
                if field.type == .checkbox {
                    answers[field.id] = "false"
                } else {
                    answers[field.id] = ""
                }
            }
        }
    }
}
