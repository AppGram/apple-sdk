import SwiftUI

struct StatusTypeBadge: View {
    let statusType: StatusType

    private var badgeTextColor: Color {
        statusType.color
    }

    private var badgeBackground: Color {
        statusType.color.opacity(0.12)
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Circle()
                .fill(statusType.color)
                .frame(width: 6, height: 6)
            Text(statusType.displayName)
                .font(.system(size: DesignSystem.Typography.xs, weight: .semibold, design: .rounded))
        }
        .foregroundColor(badgeTextColor)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.xs + 1)
        .background(
            Capsule()
                .fill(badgeBackground)
        )
        .overlay(
            Capsule()
                .strokeBorder(statusType.color.opacity(0.35), lineWidth: DesignSystem.BorderWidth.thin)
        )
    }
}
