import SwiftUI

struct StatusServiceRow: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let service: StatusPageService
    let status: StatusType?

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private var effectiveStatus: StatusType? {
        status ?? service.status
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md + 2) {
            // Service Info
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(service.name)
                        .font(.system(size: DesignSystem.Typography.sm, weight: .medium))
                        .foregroundColor(colors.text)

                    if let groupName = service.groupName {
                        Text("•")
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                            .font(.system(size: DesignSystem.Typography.xs))
                        Text(groupName)
                            .font(.system(size: DesignSystem.Typography.sm))
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                    }
                }

                if let description = service.description, !description.isEmpty {
                    Text(description)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                        .lineLimit(1)
                }
            }

            Spacer()

            // Status Indicator & Badge
            HStack(spacing: DesignSystem.Spacing.xs + 2) {
                if let status = effectiveStatus {
                    Text(status.displayName)
                        .font(.system(size: DesignSystem.Typography.sm, weight: .medium))
                        .foregroundColor(status.color)

                    Circle()
                        .fill(status.color)
                        .frame(width: 8, height: 8)
                } else {
                    Text("Unknown")
                        .font(.system(size: DesignSystem.Typography.sm, weight: .medium))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

                    Circle()
                        .fill(colors.border)
                        .frame(width: 8, height: 8)
                }
            }
        }
        .padding(.vertical, DesignSystem.Spacing.md + 2)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                .fill(colors.cardBackground)
        )
        .layeredShadow()
    }
}
