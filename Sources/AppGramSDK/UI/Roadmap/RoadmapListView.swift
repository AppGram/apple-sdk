import SwiftUI

public struct RoadmapListView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let items: [RoadmapItem]

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(items: [RoadmapItem]) {
        self.items = items
    }

    private var groupedItems: [(WishStatus, [RoadmapItem])] {
        let statuses: [WishStatus] = [.planned, .inProgress, .completed]
        return statuses.compactMap { status in
            let statusItems = items.filter { $0.status == status }
            return statusItems.isEmpty ? nil : (status, statusItems)
        }
    }

    public var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                ForEach(groupedItems, id: \.0) { status, statusItems in
                    sectionView(status: status, items: statusItems)
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
    }

    private func sectionView(status: WishStatus, items: [RoadmapItem]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: status.systemImageName)
                    .foregroundColor(statusColor(status))
                Text(status.displayName)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)
                Text("(\(items.count))")
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }

            ForEach(items) { item in
                RoadmapItemCard(item: item)
            }
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
}
