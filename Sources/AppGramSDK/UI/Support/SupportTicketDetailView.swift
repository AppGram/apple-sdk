import SwiftUI

public struct SupportTicketDetailView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: SupportDetailViewModel

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(ticket: SupportTicket, supportService: SupportServiceProtocol) {
        _viewModel = State(initialValue: SupportDetailViewModel(ticket: ticket, supportService: supportService))
    }

    public var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        headerSection
                        messagesSection
                    }
                    .padding(DesignSystem.Spacing.lg)
                }

                messageInputSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                }
            }
            ToolbarItem(placement: .principal) {
                Text("Ticket")
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
            }
        }
        .task {
            await viewModel.loadMessages()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
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
                .frame(width: 220, height: 220)
                .offset(x: 120, y: -140)
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Text(viewModel.ticket.subject)
                    .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.bold))
                    .foregroundColor(colors.text)

                Spacer()

                TicketStatusBadge(status: viewModel.ticket.status)
            }

            Text(viewModel.ticket.description)
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))

            HStack {
                Text(viewModel.ticket.userEmail)
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.neutral500)

                Spacer()

                Text(formattedDate)
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.neutral500)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
    }

    private var messagesSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Messages")
                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .padding(DesignSystem.Spacing.lg)
            } else if viewModel.messages.isEmpty {
                Text("No messages yet. Add a message to continue the conversation.")
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                    .padding(DesignSystem.Spacing.lg)
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                    ForEach(viewModel.messages) { message in
                        SupportMessageView(message: message)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }

    private var messageInputSection: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: DesignSystem.Spacing.md) {
                TextField("Type a message...", text: $viewModel.newMessageText)
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text)
                    .textFieldStyle(.plain)
                    .padding(DesignSystem.Spacing.md)
                    .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xxl))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xxl)
                            .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                    )

                Button {
                    Task { await viewModel.addMessage() }
                } label: {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .background(colors.primary)
                        .clipShape(Circle())
                }
                .disabled(viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isSubmittingMessage)
                .opacity(viewModel.newMessageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? DesignSystem.Opacity.disabled : DesignSystem.Opacity.full)
            }
            .padding(DesignSystem.Spacing.lg)
            .background(colors.background)
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: viewModel.ticket.createdAt)
    }
}
