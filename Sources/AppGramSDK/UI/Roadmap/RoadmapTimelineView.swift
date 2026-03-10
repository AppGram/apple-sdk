import SwiftUI

public struct RoadmapTimelineView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let items: [RoadmapItem]

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(items: [RoadmapItem]) {
        self.items = items
    }

    private var sortedItems: [RoadmapItem] {
        items.sorted { item1, item2 in
            let date1 = item1.targetDate ?? item1.createdAt
            let date2 = item2.targetDate ?? item2.createdAt
            return date1 < date2
        }
    }

    public var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(Array(sortedItems.enumerated()), id: \.element.id) { index, item in
                    timelineRow(item: item, isLast: index == sortedItems.count - 1)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
    }

    private func timelineRow(item: RoadmapItem, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.lg) {
            VStack(spacing: 0) {
                Circle()
                    .fill(statusColor(item.status))
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(colors.border)
                        .frame(width: DesignSystem.BorderWidth.thin)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                if let targetDate = item.targetDate {
                    Text(formattedDate(targetDate))
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.medium))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                }

                RoadmapItemCard(item: item)
            }
            .padding(.bottom, DesignSystem.Spacing.xl)
        }
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

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter.string(from: date)
    }
}
