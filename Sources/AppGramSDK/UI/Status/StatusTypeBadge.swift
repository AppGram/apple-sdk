import SwiftUI

struct StatusTypeBadge: View {
    let statusType: StatusType

    private var badgeTextColor: Color {
        switch statusType {
        case .operational, .degraded, .maintenance:
            // Darker text for lighter backgrounds
            return statusType.color.opacity(0.9)
        case .partialOutage, .majorOutage, .incident:
            // White text for darker backgrounds
            return .white
        }
    }

    private var badgeBackground: Color {
        switch statusType {
        case .operational, .degraded, .maintenance:
            // Light background with colored border
            return statusType.color.opacity(0.15)
        case .partialOutage, .majorOutage, .incident:
            // Solid color background
            return statusType.color
        }
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: statusType.iconName)
                .font(.system(size: DesignSystem.Typography.xs, weight: .semibold))
            Text(statusType.displayName)
                .font(.system(size: DesignSystem.Typography.xs, weight: .semibold, design: .rounded))
        }
        .foregroundColor(badgeTextColor)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(
            Capsule()
                .fill(badgeBackground)
        )
        .overlay(
            Capsule()
                .strokeBorder(statusType.color.opacity(0.3), lineWidth: DesignSystem.BorderWidth.thin)
        )
    }
}
