import SwiftUI

public struct RoadmapItemCard: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let item: RoadmapItem
    let compact: Bool

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(item: RoadmapItem, compact: Bool = false) {
        self.item = item
        self.compact = compact
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: compact ? DesignSystem.Spacing.xs + 2 : DesignSystem.Spacing.sm + 2) {
            Text(item.title)
                .font(.system(size: compact ? DesignSystem.Typography.sm : DesignSystem.Typography.base, weight: DesignSystem.Typography.medium))
                .foregroundColor(colors.cardText)
                .lineLimit(compact ? 2 : 3)

            if !compact, let description = item.description, !description.isEmpty {
                Text(description)
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.muted))
                    .lineLimit(2)
            }

            HStack(spacing: DesignSystem.Spacing.sm) {
                if let category = item.category {
                    CategoryBadge(category: category)
                }

                Spacer()

                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "chevron.up")
                        .font(.system(size: DesignSystem.Typography.xs - 2))
                    Text("\(item.voteCount)")
                        .font(.system(size: DesignSystem.Typography.xs))
                }
                .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.disabled))

                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: DesignSystem.Typography.xs - 2))
                    Text("\(item.commentCount)")
                        .font(.system(size: DesignSystem.Typography.xs))
                }
                .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.disabled))
            }

            if !compact, let targetDate = item.targetDate {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "calendar")
                        .font(.system(size: DesignSystem.Typography.xs - 2))
                    Text(formattedDate(targetDate))
                        .font(.system(size: DesignSystem.Typography.xs))
                }
                .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.disabled))
            }
        }
        .padding(compact ? DesignSystem.Spacing.sm + 2 : DesignSystem.Spacing.lg - 2)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg - 2))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg - 2)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
        .cardHoverEffect()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
