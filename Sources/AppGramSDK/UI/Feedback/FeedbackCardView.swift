import SwiftUI

/// Feedback card view with unified design system styling.
///
/// Features shadcn-inspired subtle borders, layered shadows, and proper spacing.
///
/// ## Example
/// ```swift
/// FeedbackCardView(
///     wish: wish,
///     onVote: { await viewModel.vote(wish.id) },
///     onRemoveVote: { await viewModel.removeVote(wish.id) }
/// )
/// ```
public struct FeedbackCardView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let wish: Wish
    let onVote: () async -> Void
    let onRemoveVote: () async -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        wish: Wish,
        onVote: @escaping () async -> Void,
        onRemoveVote: @escaping () async -> Void
    ) {
        self.wish = wish
        self.onVote = onVote
        self.onRemoveVote = onRemoveVote
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                VoteButton(
                    voteCount: wish.voteCount,
                    hasVoted: wish.hasVoted,
                    onVote: onVote,
                    onRemoveVote: onRemoveVote
                )

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(wish.title)
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.cardText)
                        .lineSpacing(2)
                        .lineLimit(2)
                        .accessibilityAddTraits(.isHeader)

                    if let description = wish.description, !description.isEmpty {
                        Text(description)
                            .font(.system(size: DesignSystem.Typography.sm))
                            .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.muted))
                            .lineSpacing(2)
                            .lineLimit(3)
                    }
                }
            }

            HStack(spacing: DesignSystem.Spacing.sm) {
                StatusBadge(status: wish.status)

                if let category = wish.category {
                    CategoryBadge(category: category)
                }

                Spacer()

                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: DesignSystem.Typography.xs))
                    Text("\(wish.commentCount)")
                        .font(.system(size: DesignSystem.Typography.xs))
                }
                .padding(.horizontal, DesignSystem.Spacing.sm)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(colors.background)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                        .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
                .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.disabled))
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("\(wish.commentCount) comments")
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .shadowStyle(DesignSystem.Shadow.xs)
        .cardHoverEffect()
    }
}
