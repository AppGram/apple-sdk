import SwiftUI

/// Release label badge with gradient background and design system styling.
///
/// ## Example
/// ```swift
/// ReleaseLabelBadge(label: label)
/// ```
struct ReleaseLabelBadge: View {
    let label: ReleaseLabel

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: label.iconName)
                .font(.system(size: DesignSystem.Typography.xs - 2, weight: DesignSystem.Typography.bold))
            Text(label.displayName)
                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
        }
        .foregroundColor(.white)
        .padding(.horizontal, DesignSystem.Spacing.sm + 2)
        .padding(.vertical, DesignSystem.Spacing.xs + 2)
        .background(
            LinearGradient(
                colors: [label.color, label.color.opacity(0.85)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(.white.opacity(0.2), lineWidth: DesignSystem.BorderWidth.hairline)
        )
        .shadow(color: label.color.opacity(0.4), radius: DesignSystem.Shadow.xs.radius, y: DesignSystem.Shadow.xs.y)
    }
}
