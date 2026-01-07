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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Circle()
                    .fill((effectiveStatus ?? .operational).color)
                    .frame(width: 10, height: 10)

                Text(service.name)
                    .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                    .foregroundColor(colors.text)
                    .lineLimit(1)

                Spacer(minLength: 0)
            }

            if let groupName = service.groupName {
                Text(groupName)
                    .font(.system(size: DesignSystem.Typography.xs, weight: .medium))
                    .foregroundColor(colors.neutral500)
            }

            if let description = service.description, !description.isEmpty {
                Text(description)
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.neutral500)
                    .lineLimit(2)
            }

            Spacer(minLength: 0)

            HStack {
                if let status = effectiveStatus {
                    StatusTypeBadge(statusType: status)
                } else {
                    Text("Unknown")
                        .font(.system(size: DesignSystem.Typography.xs, weight: .medium))
                        .foregroundColor(colors.neutral500)
                }

                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
    }
}
