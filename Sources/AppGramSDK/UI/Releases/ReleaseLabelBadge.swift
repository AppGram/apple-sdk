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
            Circle()
                .fill(label.color)
                .frame(width: 6, height: 6)
            Text(label.displayName)
                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
        }
        .foregroundColor(label.color)
        .padding(.horizontal, DesignSystem.Spacing.sm + 2)
        .padding(.vertical, DesignSystem.Spacing.xs + 2)
        .background(label.color.opacity(0.12))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .strokeBorder(label.color.opacity(0.3), lineWidth: DesignSystem.BorderWidth.hairline)
        )
    }
}
