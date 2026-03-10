import SwiftUI

public struct SupportFormView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var subject = ""
    @State private var description = ""
    @State private var answers: [String: String] = [:]
    @State private var fieldErrors: [String: String] = [:]
    @State private var isSubmitting = false
    @State private var isSubmitted = false
    @State private var error: AppGramError?

    private let form: SupportForm
    private let supportService: SupportServiceProtocol
    private let userContextProvider: @Sendable () -> UserContext?
    private let onDismiss: () -> Void
    private let embedded: Bool

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        form: SupportForm,
        supportService: SupportServiceProtocol,
        userContextProvider: @escaping @Sendable () -> UserContext?,
        embedded: Bool = false,
        onDismiss: @escaping () -> Void
    ) {
        self.form = form
        self.supportService = supportService
        self.userContextProvider = userContextProvider
        self.embedded = embedded
        self.onDismiss = onDismiss
    }

    public var body: some View {
        Group {
            if embedded {
                // Embedded mode - no NavigationStack, just content with toolbar
                content
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: {
                                onDismiss()
                                dismiss()
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                            }
                        }
                        ToolbarItem(placement: .principal) {
                            Text(form.name)
                                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                        }
                    }
                    .navigationBarBackButtonHidden()
            } else {
                // Standalone mode - with NavigationStack and Cancel button
                NavigationStack {
                    content
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button(action: {
                                    onDismiss()
                                    dismiss()
                                }) {
                                    Image(systemName: "xmark")
                                        .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                                }
                            }
                            ToolbarItem(placement: .principal) {
                                Text(form.name)
                                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                            }
                        }
                        .navigationBarBackButtonHidden()
                }
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if isSubmitted {
            successView
        } else {
            formView
        }
    }

    private var formView: some View {
        ZStack {
            backgroundView

            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    headerCard

                    // Subject field
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Subject")
                            .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text)

                        TextField("Brief description of your issue", text: $subject)
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                            .foregroundColor(colors.text)
                            .textFieldStyle(.plain)
                            .padding(DesignSystem.Spacing.md)
                            .background(colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                    .strokeBorder(fieldErrors["subject"] != nil ? colors.error : colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                            )
                            .layeredShadow()

                        if let error = fieldErrors["subject"] {
                            Text(error)
                                .font(.system(size: DesignSystem.Typography.xs))
                                .foregroundColor(colors.error)
                        }
                    }

                    // Description field
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text("Description")
                            .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text)

                        TextEditor(text: $description)
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                            .foregroundColor(colors.text)
                            .scrollContentBackground(.hidden)
                            .frame(minHeight: 120)
                            .padding(DesignSystem.Spacing.sm)
                            .background(colors.cardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                    .strokeBorder(fieldErrors["description"] != nil ? colors.error : colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                            )
                            .layeredShadow()

                        if let error = fieldErrors["description"] {
                            Text(error)
                                .font(.system(size: DesignSystem.Typography.xs))
                                .foregroundColor(colors.error)
                        }
                    }

                    // Form description
                    if let formDescription = form.description {
                        Text(formDescription)
                            .font(.system(size: DesignSystem.Typography.sm))
                            .foregroundColor(colors.neutral500)
                    }

                    // Form fields
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        ForEach(sortedFields(form.fields)) { field in
                            fieldView(for: field)
                        }
                    }

                    // Error banner
                    if let error = error {
                        errorBanner(error)
                    }

                    // Submit button
                    submitButton
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }
    }

    private func sortedFields(_ fields: [FormField]) -> [FormField] {
        fields.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
    }

    @ViewBuilder
    private func fieldView(for field: FormField) -> some View {
        let binding = Binding<String>(
            get: { answers[field.id] ?? "" },
            set: { answers[field.id] = $0 }
        )
        let error = fieldErrors[field.id]

        switch field.type {
        case .text:
            FormTextFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { validateField(field.id) }
            )

        case .email:
            FormEmailFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { validateField(field.id) }
            )

        case .textarea:
            FormTextAreaView(
                field: field,
                value: binding,
                error: error,
                onValidate: { validateField(field.id) }
            )

        case .select:
            FormSelectFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { validateField(field.id) }
            )

        case .radio:
            FormRadioFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { validateField(field.id) }
            )

        case .checkbox:
            FormCheckboxFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { validateField(field.id) }
            )
        }
    }

    private func validateField(_ fieldId: String) {
        fieldErrors[fieldId] = nil

        if fieldId == "subject" {
            if subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fieldErrors["subject"] = "Subject is required"
            }
        } else if fieldId == "description" {
            if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                fieldErrors["description"] = "Description is required"
            }
        } else if let field = form.fields.first(where: { $0.id == fieldId }) {
            let value = answers[fieldId] ?? ""

            if field.required && value.isEmpty {
                fieldErrors[fieldId] = "\(field.label) is required"
            } else if let validation = field.validation {
                if let minLength = validation.minLength, value.count < minLength {
                    fieldErrors[fieldId] = "\(field.label) must be at least \(minLength) characters"
                } else if let maxLength = validation.maxLength, value.count > maxLength {
                    fieldErrors[fieldId] = "\(field.label) must be no more than \(maxLength) characters"
                }
            }
        }
    }

    private func validateAllFields() -> Bool {
        fieldErrors = [:]

        // Validate subject
        if subject.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fieldErrors["subject"] = "Subject is required"
        }

        // Validate description
        if description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            fieldErrors["description"] = "Description is required"
        }

        // Validate form fields
        for field in form.fields {
            let value = answers[field.id] ?? ""

            if field.required && value.isEmpty {
                fieldErrors[field.id] = "\(field.label) is required"
            } else if let validation = field.validation {
                if let minLength = validation.minLength, value.count < minLength {
                    fieldErrors[field.id] = "\(field.label) must be at least \(minLength) characters"
                } else if let maxLength = validation.maxLength, value.count > maxLength {
                    fieldErrors[field.id] = "\(field.label) must be no more than \(maxLength) characters"
                }
            }
        }

        return fieldErrors.isEmpty
    }

    private func errorBanner(_ error: AppGramError) -> some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(colors.error)

            Text(error.localizedDescription)
                .font(.system(size: DesignSystem.Typography.sm))
                .foregroundColor(colors.error)

            Spacer()

            Button {
                self.error = nil
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.error)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(colors.error.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
    }

    private var submitButton: some View {
        Button {
            Task {
                await submit()
            }
        } label: {
            HStack {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(form.submitButtonText)
                        .fontWeight(DesignSystem.Typography.semibold)
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.md)
            .background(isSubmitting ? colors.primary.opacity(0.6) : colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
        }
        .disabled(isSubmitting)
        .padding(.top, DesignSystem.Spacing.sm)
    }

    private func submit() async {
        guard validateAllFields() else {
            return
        }

        isSubmitting = true
        error = nil

        let userContext = userContextProvider()

        do {
            // For default form, use the public portal endpoint via createTicket
            // For custom forms from API, use submitSupportForm
            if form.id == "default_support_form" {
                // Get email from form field or user context
                let email = answers["user_email"] ?? userContext?.email ?? ""
                let ticket = try await supportService.createTicket(
                    subject: subject.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                    priority: .low,
                    email: email,
                    attachmentUrls: nil
                )
                // Save ticket to local storage for "My Tickets" view
                SupportTicketStorage.shared.saveTicket(ticket)
            } else {
                try await supportService.submitSupportForm(
                    formId: form.id,
                    subject: subject.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                    data: answers, 
                    userEmail: userContext?.email,
                    userName: userContext?.name
                )
            }
            isSubmitted = true
        } catch let err as AppGramError {
            error = err
        } catch let networkErr {
            error = .networkError(networkErr.localizedDescription)
        }

        isSubmitting = false
    }

    private var successView: some View {
        ZStack {
            backgroundView

            VStack(spacing: DesignSystem.Spacing.xl) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundColor(colors.success)

                Text("Thank You!")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(colors.text)

                if let message = form.successMessage {
                    Text(message)
                        .font(.body)
                        .foregroundColor(colors.neutral500)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Your support request has been submitted!")
                        .font(.body)
                        .foregroundColor(colors.neutral500)
                        .multilineTextAlignment(.center)
                }

                Button {
                    onDismiss()
                } label: {
                    Text("Done")
                        .fontWeight(DesignSystem.Typography.semibold)
                        .foregroundColor(colors.cardBackground)
                        .frame(maxWidth: .infinity)
                        .padding(DesignSystem.Spacing.md)
                        .background(colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                }
                .padding(.top, DesignSystem.Spacing.md)
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                    .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
            )
            .padding(DesignSystem.Spacing.lg)
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [colors.background, colors.neutral100],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Circle()
                .fill(colors.neutral200.opacity(0.35))
                .frame(width: 240, height: 240)
                .offset(x: 140, y: -160)
        )
        .ignoresSafeArea()
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(form.name)
                .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.semibold, design: .serif))
                .foregroundColor(colors.text)

            Text("Share the details and we’ll route it to the right team.")
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.neutral500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }
}
