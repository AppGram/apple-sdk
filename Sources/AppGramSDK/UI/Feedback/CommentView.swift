import SwiftUI

public struct CommentView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let comment: Comment

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(comment: Comment) {
        self.comment = comment
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Circle()
                    .fill(comment.isOfficial ? colors.primary : colors.secondary)
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(authorInitials)
                            .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(.white)
                    )
                    .accessibilityHidden(true)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text(comment.authorName ?? "Anonymous")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                            .foregroundColor(colors.text)

                        if comment.isOfficial {
                            Text("Official")
                                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, DesignSystem.Spacing.xs)
                                .padding(.vertical, DesignSystem.Spacing.xs)
                                .background(colors.primary)
                                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
                        }
                    }

                    Text(formattedDate)
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                }

                Spacer()
            }

            Text(comment.content)
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
        }
        .padding(DesignSystem.Spacing.lg)
        .background(comment.isOfficial ? colors.primary.opacity(0.05) : colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .shadowStyle(DesignSystem.Shadow.xs)
        .accessibilityElement(children: .combine)
    }

    private var authorInitials: String {
        guard let name = comment.authorName, !name.isEmpty else {
            return "?"
        }
        let components = name.split(separator: " ")
        let initials = components.prefix(2).compactMap { $0.first }.map(String.init).joined()
        return initials.isEmpty ? "?" : initials.uppercased()
    }

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: comment.createdAt, relativeTo: Date())
    }
}
