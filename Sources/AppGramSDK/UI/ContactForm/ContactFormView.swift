import SwiftUI

public struct ContactFormView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: ContactFormViewModel

    private let formId: String
    private let useStandaloneEndpoint: Bool

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        formId: String,
        contactFormService: ContactFormServiceProtocol,
        projectId: String,
        userContextProvider: @escaping @Sendable () -> UserContext?,
        useStandaloneEndpoint: Bool = false
    ) {
        self.formId = formId
        self.useStandaloneEndpoint = useStandaloneEndpoint
        _viewModel = State(initialValue: ContactFormViewModel(
            contactFormService: contactFormService,
            projectId: projectId,
            userContextProvider: userContextProvider
        ))
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle(viewModel.form?.name ?? "Contact Form")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            dismiss()
                        }
                    }
                }
        }
        .task {
            await viewModel.loadForm(formId: formId, useStandaloneEndpoint: useStandaloneEndpoint)
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            LoadingView()
        } else if let error = viewModel.error, viewModel.form == nil {
            ErrorView(error: error) {
                await viewModel.loadForm(formId: formId)
            }
        } else if viewModel.isSubmitted {
            successView
        } else if let form = viewModel.form {
            formView(form)
        } else {
            EmptyStateView(
                icon: "doc.text",
                title: "Form Not Found",
                message: "This form is no longer available."
            )
        }
    }

    private func formView(_ form: ContactForm) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                if let description = form.description {
                    Text(description)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                }

                VStack(spacing: DesignSystem.Spacing.lg) {
                    ForEach(sortedFields(form.fields)) { field in
                        fieldView(for: field)
                    }
                }

                if let error = viewModel.error {
                    errorBanner(error)
                }

                submitButton(form)
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
    }

    private func sortedFields(_ fields: [FormField]) -> [FormField] {
        fields.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
    }

    @ViewBuilder
    private func fieldView(for field: FormField) -> some View {
        let binding = Binding<String>(
            get: { viewModel.answers[field.id] ?? "" },
            set: { viewModel.answers[field.id] = $0 }
        )
        let error = viewModel.fieldErrors[field.id]

        switch field.type {
        case .text:
            FormTextFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { viewModel.validateField(field.id) }
            )

        case .email:
            FormEmailFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { viewModel.validateField(field.id) }
            )

        case .textarea:
            FormTextAreaView(
                field: field,
                value: binding,
                error: error,
                onValidate: { viewModel.validateField(field.id) }
            )

        case .select:
            FormSelectFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { viewModel.validateField(field.id) }
            )

        case .radio:
            FormRadioFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { viewModel.validateField(field.id) }
            )

        case .checkbox:
            FormCheckboxFieldView(
                field: field,
                value: binding,
                error: error,
                onValidate: { viewModel.validateField(field.id) }
            )
        }
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
                viewModel.clearError()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.error)
            }
        }
        .padding(DesignSystem.Spacing.md)
        .background(colors.error.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
        .shadowStyle(DesignSystem.Shadow.xs)
    }

    private func submitButton(_ form: ContactForm) -> some View {
        Button {
            Task {
                await viewModel.submit()
            }
        } label: {
            HStack {
                if viewModel.isSubmitting {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                } else {
                    Text(form.submitButtonText)
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(DesignSystem.Spacing.lg)
            .background(viewModel.isSubmitting ? colors.primary.opacity(0.6) : colors.primary)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
        }
        .disabled(viewModel.isSubmitting)
        .padding(.top, 8)
    }

    private var successView: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(colors.success)

            Text("Thank You!")
                .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.bold))
                .foregroundColor(colors.text)

            if let message = viewModel.form?.successMessage {
                Text(message)
                    .font(.body)
                    .foregroundColor(colors.text.opacity(0.8))
                    .multilineTextAlignment(.center)
            } else {
                Text("Your submission has been received.")
                    .font(.body)
                    .foregroundColor(colors.text.opacity(0.8))
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: DesignSystem.Spacing.md) {
                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(DesignSystem.Spacing.lg)
                        .background(colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                }

                Button {
                    viewModel.reset()
                } label: {
                    Text("Submit Another Response")
                        .font(.system(size: DesignSystem.Typography.base, weight: .medium))
                        .foregroundColor(colors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(DesignSystem.Spacing.lg)
                        .background(colors.cardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                        )
                }
            }
            .padding(.top)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
    }
}
