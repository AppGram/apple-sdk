import SwiftUI

public struct SupportFormSelectionView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var forms: [SupportForm] = []
    @State private var isLoading = false
    @State private var error: AppGramError?
    @State private var selectedForm: SupportForm?
    @State private var specificForm: SupportForm?

    private let supportService: SupportServiceProtocol
    private let userContextProvider: @Sendable () -> UserContext?
    private let onDismiss: () -> Void
    private let formId: String?
    private let embedded: Bool

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        supportService: SupportServiceProtocol,
        userContextProvider: @escaping @Sendable () -> UserContext?,
        formId: String? = nil,
        embedded: Bool = false,
        onDismiss: @escaping () -> Void
    ) {
        self.supportService = supportService
        self.userContextProvider = userContextProvider
        self.formId = formId
        self.embedded = embedded
        self.onDismiss = onDismiss
    }

    public var body: some View {
        Group {
            if embedded {
                // Embedded mode - use NavigationLink instead of sheets
                NavigationStack {
                    content
                        .navigationDestination(for: SupportForm.self) { form in
                            SupportFormView(
                                form: form,
                                supportService: supportService,
                                userContextProvider: userContextProvider,
                                embedded: true
                            ) {
                                // Navigation will handle going back
                            }
                        }
                }
            } else {
                // Standalone mode - with NavigationStack
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
                                Text("New Support Request")
                                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                            }
                        }
                        .sheet(item: $selectedForm) { form in
                            NavigationStack {
                                SupportFormView(
                                    form: form,
                                    supportService: supportService,
                                    userContextProvider: userContextProvider,
                                    embedded: true
                                ) {
                                    onDismiss()
                                }
                            }
                        }
                }
            }
        }
        .task {
            if let formId = formId {
                await loadSpecificForm(formId: formId)
            } else {
                await loadForms()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if let specificForm = specificForm {
            // Show specific form directly
            if embedded {
                // Embedded mode - wrap in NavigationStack for form view
                NavigationStack {
                    SupportFormView(
                        form: specificForm,
                        supportService: supportService,
                        userContextProvider: userContextProvider,
                        embedded: true
                    ) {
                        onDismiss()
                    }
                }
            } else {
                SupportFormView(
                    form: specificForm,
                    supportService: supportService,
                    userContextProvider: userContextProvider,
                    embedded: false
                ) {
                    onDismiss()
                }
            }
        } else if isLoading {
            LoadingView()
        } else if let error = error {
            ErrorView(error: error) {
                if let formId = formId {
                    await loadSpecificForm(formId: formId)
                } else {
                    await loadForms()
                }
            }
        } else if forms.isEmpty {
            EmptyStateView(
                icon: "doc.text",
                title: "No Forms Available",
                message: "There are no support forms available at this time."
            )
        } else {
            formList
        }
    }

    private var formList: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.lg) {
                headerCard

                LazyVStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(forms.filter { $0.isFormActive }) { form in
                        if embedded {
                            // Embedded mode - use NavigationLink
                            NavigationLink(value: form) {
                                formCard(for: form)
                            }
                        } else {
                            // Standalone mode - use button to trigger sheet
                            Button {
                                selectedForm = form
                            } label: {
                                formCard(for: form)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Start a support request")
                .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.semibold, design: .serif))
                .foregroundColor(colors.text)

            Text("Pick a form and we’ll capture the right details up front.")
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
    
    private func formCard(for form: SupportForm) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(form.name)
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let description = form.description {
                Text(description)
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(2)
            }

            HStack {
                Text("\(form.fields.count) field\(form.fields.count == 1 ? "" : "s")")
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
    }

    private func loadForms() async {
        isLoading = true
        error = nil

        do {
            forms = try await supportService.getSupportForms()
        } catch let err as AppGramError {
            error = err
        } catch let networkErr {
            error = .networkError(networkErr.localizedDescription)
        }

        isLoading = false
    }

    private func loadSpecificForm(formId: String) async {
        isLoading = true
        error = nil

        do {
            let form = try await supportService.getSupportForm(formId: formId)
            specificForm = form
        } catch let err as AppGramError {
            error = err
        } catch let networkErr {
            error = .networkError(networkErr.localizedDescription)
        }

        isLoading = false
    }
}
