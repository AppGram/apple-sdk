import SwiftUI

public struct FeedbackSubmissionView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var title = ""
    @State private var description = ""
    @State private var isSubmitting = false
    @State private var isSubmitted = false
    @State private var error: AppGramError?
    @FocusState private var focusedField: Field?

    private enum Field {
        case title, description
    }

    private let feedbackService: FeedbackViewModel
    private let strings: FeedbackStrings
    private let onDismiss: () -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    internal init(
        feedbackService: FeedbackViewModel,
        strings: FeedbackStrings = .default,
        onDismiss: @escaping () -> Void
    ) {
        self.feedbackService = feedbackService
        self.strings = strings
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        titleSection
                        descriptionSection
                        submitButton

                        Color.clear
                            .frame(height: 1)
                            .id("bottom")
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                .scrollDismissesKeyboard(.interactively)
                .onChange(of: focusedField) { _, newValue in
                    if newValue != nil {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            withAnimation {
                                proxy.scrollTo("bottom", anchor: .bottom)
                            }
                        }
                    }
                }
            }
            .background(colors.background)
            .navigationTitle(strings.submitTitle)
            .navigationBarTitleDisplayMode(.inline)
            .overlay {
                if isSubmitted {
                    ZStack {
                        colors.background
                        VStack(spacing: DesignSystem.Spacing.md) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(colors.primary)
                            Text(strings.submittedMessage)
                                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.bold))
                                .foregroundColor(colors.text)
                        }
                        .scaleEffect(isSubmitted ? 1.0 : 0.5)
                        .opacity(isSubmitted ? 1.0 : 0.0)
                    }
                    .transition(.opacity)
                    .accessibilityElement(children: .combine)
                    .accessibilityAddTraits(.isModal)
                    .accessibilityLabel(strings.submittedMessage)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(strings.cancelButtonLabel) {
                        onDismiss()
                    }
                }
            }
            .alert("Error", isPresented: .constant(error != nil)) {
                Button("OK") { error = nil }
            } message: {
                if let error = error {
                    Text(error.localizedDescription)
                }
            }
        }
    }

    private var titleSection: some View {
        sectionCard {
            Text(strings.titleLabel)
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            Text(strings.titleHint)
                .font(.system(size: DesignSystem.Typography.xs))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

            TextField(strings.titlePlaceholder, text: $title)
                .font(.system(size: DesignSystem.Typography.base))
                .textFieldStyle(.plain)
                .textInputAutocapitalization(.sentences)
                .submitLabel(.next)
                .focused($focusedField, equals: .title)
                .onSubmit {
                    focusedField = .description
                }
                .padding(DesignSystem.Spacing.md)
                .background(colors.background)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
                .accessibilityLabel(strings.titleLabel)
                .accessibilityHint(strings.titleHint)
        }
    }

    private var descriptionSection: some View {
        sectionCard {
            Text(strings.descriptionLabel)
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            Text(strings.descriptionHint)
                .font(.system(size: DesignSystem.Typography.xs))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

            TextEditor(text: $description)
                .font(.system(size: DesignSystem.Typography.sm))
                .textInputAutocapitalization(.sentences)
                .frame(minHeight: 120)
                .padding(DesignSystem.Spacing.sm)
                .scrollContentBackground(.hidden)
                .focused($focusedField, equals: .description)
                .background(colors.background)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
                .accessibilityLabel(strings.descriptionLabel)
                .accessibilityHint(strings.descriptionHint)
        }
    }

    private var submitButton: some View {
        PrimaryButton(strings.submitButtonLabel, isLoading: isSubmitting) {
            Task { await submit() }
        }
        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .padding(.top, DesignSystem.Spacing.sm)
        .accessibilityHint("Submits your feedback.")
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            content()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .shadowStyle(DesignSystem.Shadow.xs)
    }

    private func submit() async {
        isSubmitting = true
        let success = await feedbackService.submitFeedback(
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : description,
            categoryId: nil
        )
        isSubmitting = false

        if success {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                isSubmitted = true
            }

            try? await Task.sleep(nanoseconds: 800_000_000)
            onDismiss()
        } else {
            error = feedbackService.error
        }
    }
}
