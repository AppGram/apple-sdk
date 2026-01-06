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
        VStack(spacing: 0) {
            HStack(spacing: DesignSystem.Spacing.lg) {
                // Status Indicator
                Circle()
                    .fill(status.color)
                    .frame(width: 12, height: 12)
                    .shadowStyle(DesignSystem.Shadow.sm)

                // Status Text
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text(statusMessage)
                        .font(.system(size: DesignSystem.Typography.lg, weight: .semibold))
                        .foregroundColor(colors.text)

                    HStack(spacing: DesignSystem.Spacing.xs + 2) {
                        StatusTypeBadge(statusType: status)
                    }
                }

                Spacer()
            }
            .padding(DesignSystem.Spacing.xl)
        }
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .fill(status.color.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .strokeBorder(status.color.opacity(0.2), lineWidth: DesignSystem.BorderWidth.thin)
        )
    }
}
