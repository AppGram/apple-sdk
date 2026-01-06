import SwiftUI
import PhotosUI

public struct SupportSubmissionView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var subject = ""
    @State private var description = ""
    @State private var email = ""
    @State private var priority: TicketPriority = .medium
    @State private var selectedPhotos: [PhotosPickerItem] = []
    @State private var attachmentUrls: [String] = []
    @State private var isUploading = false

    private let viewModel: SupportViewModel
    private let onDismiss: () -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    internal init(viewModel: SupportViewModel, onDismiss: @escaping () -> Void) {
        self.viewModel = viewModel
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    subjectSection
                    emailSection
                    descriptionSection
                    prioritySection
                    attachmentsSection
                    submitButton
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .background(colors.background)
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
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
                    Text("New Ticket")
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                }
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                if let error = viewModel.error {
                    Text(error.localizedDescription)
                }
            }
        }
    }

    private var subjectSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Subject")
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            TextField("Brief description of your issue", text: $subject)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text)
                .textFieldStyle(.plain)
                .padding(DesignSystem.Spacing.lg)
                .background(colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
        }
    }

    private var emailSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Email")
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            TextField("your@email.com", text: $email)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text)
                .textFieldStyle(.plain)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
                .padding(DesignSystem.Spacing.lg)
                .background(colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
        }
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Description")
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            Text("Provide as much detail as possible")
                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

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
                        .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
        }
    }

    private var prioritySection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Priority")
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            Picker("Priority", selection: $priority) {
                ForEach(TicketPriority.allCases, id: \.self) { p in
                    Text(p.displayName).tag(p)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var attachmentsSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text("Attachments")
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            PhotosPicker(
                selection: $selectedPhotos,
                maxSelectionCount: 5,
                matching: .images
            ) {
                HStack {
                    Image(systemName: "photo.on.rectangle.angled")
                    Text("Add Photos")
                }
                .foregroundColor(colors.primary)
                .padding(DesignSystem.Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(colors.primary.opacity(DesignSystem.Opacity.muted))
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
            }
            .onChange(of: selectedPhotos) { _, newItems in
                Task {
                    await uploadPhotos(newItems)
                }
            }

            if !attachmentUrls.isEmpty {
                HStack {
                    ForEach(attachmentUrls, id: \.self) { url in
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "photo")
                            Text("Image")
                        }
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.primary)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(colors.primary.opacity(DesignSystem.Opacity.muted))
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm))
                    }
                }
            }
        }
    }

    private var submitButton: some View {
        PrimaryButton(
            "Submit Ticket",
            isLoading: viewModel.isSubmitting || isUploading
        ) {
            Task { await submit() }
        }
        .disabled(subject.isEmpty || description.isEmpty || email.isEmpty)
        .padding(.top, DesignSystem.Spacing.sm)
    }

    private func uploadPhotos(_ items: [PhotosPickerItem]) async {
        isUploading = true
        attachmentUrls = []

        for item in items {
            guard let data = try? await item.loadTransferable(type: Data.self) else {
                continue
            }

            if let url = await viewModel.uploadFile(data, fileName: "photo.jpg", mimeType: "image/jpeg") {
                attachmentUrls.append(url)
            }
        }

        isUploading = false
    }

    private func submit() async {
        let success = await viewModel.createTicket(
            subject: subject.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            attachmentUrls: attachmentUrls.isEmpty ? nil : attachmentUrls
        )

        if success {
            onDismiss()
        }
    }
}
