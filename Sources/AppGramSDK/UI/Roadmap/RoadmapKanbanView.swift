import SwiftUI

public struct RoadmapKanbanView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let columns: [RoadmapColumn]

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(columns: [RoadmapColumn]) {
        self.columns = columns
    }

    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.lg) {
                ForEach(columns) { column in
                    columnView(column)
                        .frame(width: 280)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
    }

    private func columnView(_ column: RoadmapColumn) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: column.status.systemImageName)
                    .foregroundColor(statusColor(column.status))
                Text(column.status.displayName)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)
                Text("(\(column.items.count))")
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }
            .padding(.horizontal, DesignSystem.Spacing.xs)

            ScrollView {
                LazyVStack(spacing: DesignSystem.Spacing.sm) {
                    ForEach(column.items) { item in
                        RoadmapItemCard(item: item, compact: true)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground.opacity(DesignSystem.Opacity.subtle))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
    }

    private func statusColor(_ status: WishStatus) -> Color {
        switch status {
        case .planned:
            return colors.primary
        case .inProgress:
            return colors.warning
        case .completed:
            return colors.success
        default:
            return colors.text.opacity(DesignSystem.Opacity.muted)
        }
    }
}
