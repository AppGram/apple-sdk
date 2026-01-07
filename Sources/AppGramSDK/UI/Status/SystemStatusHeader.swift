import SwiftUI

struct SystemStatusHeader: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let status: StatusType
    let configuration: StatusConfiguration

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private var statusMessage: String {
        switch status {
        case .operational:
            return "All systems operational"
        case .maintenance:
            return "Scheduled maintenance in progress"
        case .degraded:
            return "Some services experiencing issues"
        case .partialOutage:
            return "Partial service disruption"
        case .majorOutage:
            return "Major service outage"
        case .incident:
            return "Active incident in progress"
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(configuration.title)
                .font(.system(size: DesignSystem.Typography.xl, weight: .semibold, design: .serif))
                .foregroundColor(colors.text)

            HStack(spacing: DesignSystem.Spacing.lg) {
                Circle()
                    .fill(status.color)
                    .frame(width: 12, height: 12)
                    .shadowStyle(DesignSystem.Shadow.sm)

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(statusMessage)
                        .font(.system(size: DesignSystem.Typography.lg, weight: .semibold))
                        .foregroundColor(colors.text)

                    StatusTypeBadge(statusType: status)
                }

                Spacer()
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }
}
