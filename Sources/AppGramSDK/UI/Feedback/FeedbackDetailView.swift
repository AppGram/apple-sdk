import SwiftUI

public struct FeedbackDetailView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: FeedbackDetailViewModel
    @FocusState private var isCommentFocused: Bool

    private let strings: FeedbackStrings

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(wish: Wish, feedbackService: FeedbackServiceProtocol, strings: FeedbackStrings = .default) {
        _viewModel = State(initialValue: FeedbackDetailViewModel(wish: wish, feedbackService: feedbackService))
        self.strings = strings
    }

    public var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    headerSection
                    descriptionSection
                    commentsSection
                    commentInputSection

                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .scrollDismissesKeyboard(.interactively)
            .onChange(of: isCommentFocused) { _, focused in
                if focused {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }
            }
        }
        .background(colors.background)
        .navigationTitle(strings.detailTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(strings.closeButtonLabel) {
                    dismiss()
                }
            }
        }
        .task {
            await viewModel.loadComments()
        }
        .alert("Error", isPresented: .constant(viewModel.error != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            if let error = viewModel.error {
                Text(error.localizedDescription)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                VoteButton(
                    voteCount: viewModel.wish.voteCount,
                    hasVoted: viewModel.wish.hasVoted,
                    onVote: { await viewModel.vote() },
                    onRemoveVote: { await viewModel.removeVote() }
                )

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text(viewModel.wish.title)
                        .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.bold))
                        .foregroundColor(colors.text)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineSpacing(2)
                        .accessibilityAddTraits(.isHeader)

                    HStack(spacing: DesignSystem.Spacing.sm) {
                        StatusBadge(status: viewModel.wish.status)
                        if let category = viewModel.wish.category {
                            CategoryBadge(category: category)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            HStack(spacing: DesignSystem.Spacing.sm) {
                if let authorName = viewModel.wish.authorName {
                    Text("\(strings.byAuthorPrefix) \(authorName)")
                        .font(.system(size: DesignSystem.Typography.xs))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                }

                Text(formattedDate)
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.disabled))
            }
            .accessibilityElement(children: .combine)
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .shadowStyle(DesignSystem.Shadow.xs)
    }

    @ViewBuilder
    private var descriptionSection: some View {
        if let description = viewModel.wish.description, !description.isEmpty {
            sectionCard {
                Text(strings.descriptionLabel)
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                Text(description)
                    .font(.system(size: DesignSystem.Typography.base))
                    .foregroundColor(colors.text.opacity(0.9))
                    .lineSpacing(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var commentsSection: some View {
        sectionCard {
            HStack {
                Text(strings.commentsLabel)
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                Text("(\(viewModel.comments.count))")
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.disabled))

                Spacer()
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(strings.commentsLabel)
            .accessibilityValue("\(viewModel.comments.count)")

            if viewModel.isLoading {
                HStack {
                    Spacer()
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: colors.primary))
                        .accessibilityLabel("Loading comments.")
                    Spacer()
                }
                .padding(DesignSystem.Spacing.lg)
            } else if viewModel.comments.isEmpty {
                Text(strings.noCommentsMessage)
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.disabled))
                    .padding(DesignSystem.Spacing.lg)
            } else {
                LazyVStack(spacing: DesignSystem.Spacing.md) {
                    ForEach(viewModel.comments) { comment in
                        CommentView(comment: comment)
                    }
                }
            }
        }
    }

    private var commentInputSection: some View {
        sectionCard {
            Text(strings.addCommentLabel)
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            TextEditor(text: $viewModel.newCommentText)
                .font(.system(size: DesignSystem.Typography.sm))
                .textInputAutocapitalization(.sentences)
                .frame(minHeight: 100)
                .padding(DesignSystem.Spacing.sm)
                .scrollContentBackground(.hidden)
                .focused($isCommentFocused)
                .background(colors.background)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
                .accessibilityLabel(strings.addCommentLabel)
                .accessibilityHint("Enter your comment.")

            PrimaryButton(strings.postCommentLabel, isLoading: viewModel.isSubmittingComment) {
                Task { await viewModel.addComment() }
            }
            .disabled(viewModel.newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            .accessibilityHint("Posts your comment.")
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: viewModel.wish.createdAt)
    }

    private func sectionCard<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            content()
        }
        .padding(DesignSystem.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .shadowStyle(DesignSystem.Shadow.xs)
    }
}
