import SwiftUI

public struct VoteButton: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let voteCount: Int
    let hasVoted: Bool
    let onVote: () async -> Void
    let onRemoveVote: () async -> Void

    @State private var isProcessing = false
    @State private var isPressed: Bool = false

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        voteCount: Int,
        hasVoted: Bool = false,
        onVote: @escaping () async -> Void,
        onRemoveVote: @escaping () async -> Void
    ) {
        self.voteCount = voteCount
        self.hasVoted = hasVoted
        self.onVote = onVote
        self.onRemoveVote = onRemoveVote
    }

    public var body: some View {
        Button {
            guard !isProcessing else { return }
            isProcessing = true
            Task {
                if hasVoted {
                    await onRemoveVote()
                } else {
                    await onVote()
                }
                isProcessing = false
            }
        } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 14, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(hasVoted ? .white : colors.text.opacity(DesignSystem.Opacity.muted))
                
                Text("\(voteCount)")
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(hasVoted ? .white : colors.text)
            }
            .frame(width: 48, height: 56)
            .background(hasVoted ? colors.primary : colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .strokeBorder(
                        hasVoted ? Color.clear : colors.neutral200,
                        lineWidth: DesignSystem.BorderWidth.thin
                    )
            )
            .shadowStyle(hasVoted ? DesignSystem.Shadow.sm : DesignSystem.Shadow.xs)
        }
        .buttonStyle(.plain)
        .disabled(isProcessing)
        .accessibilityLabel(hasVoted ? "Remove vote" : "Upvote")
        .accessibilityValue("\(voteCount) votes")
        .accessibilityHint(hasVoted ? "Removes your vote from this feedback." : "Adds your vote to this feedback.")
        .accessibilityAddTraits(hasVoted ? .isSelected : [])
        .scaleEffect(isPressed ? 0.97 : 1.0)
        .animation(DesignSystem.Animation.spring, value: hasVoted)
        .animation(DesignSystem.Animation.spring, value: isPressed)
        .animation(DesignSystem.Animation.spring, value: isProcessing)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed && !isProcessing {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}
