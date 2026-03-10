import SwiftUI

/// A card view that displays a help flow.
///
/// ## Discussion
/// This view renders a help flow as a tappable card with icon, title, description,
/// and display type badge.
internal struct HelpFlowCard: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let flow: HelpFlow

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .top) {
                // Icon
                if let icon = flow.icon, !icon.isEmpty {
                    Image(systemName: icon)
                        .font(.system(size: DesignSystem.Typography.xxl))
                        .foregroundColor(iconColor)
                        .frame(width: 40, height: 40)
                        .background(iconColor.opacity(DesignSystem.Opacity.disabled / 4))
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                } else {
                    Image(systemName: "book.fill")
                        .font(.system(size: DesignSystem.Typography.xxl))
                        .foregroundColor(colors.primary)
                        .frame(width: 40, height: 40)
                        .background(colors.primary.opacity(DesignSystem.Opacity.disabled / 4))
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    HStack {
                        Text(flow.name)
                            .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text)
                            .lineLimit(2)

                        Spacer()

                        // Display type badge
                        if let displayType = flow.displayType {
                            displayTypeBadge(displayType)
                        }
                    }

                    if let description = flow.description {
                        Text(description)
                            .font(.system(size: DesignSystem.Typography.sm))
                            .foregroundColor(colors.neutral500)
                            .lineLimit(2)
                    }
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(iconColor)
                .frame(width: 4)
                .padding(.vertical, DesignSystem.Spacing.md)
                .offset(x: 2)
        }
        .layeredShadow()
    }

    private var iconColor: Color {
        if let color = flow.color, !color.isEmpty {
            return Color(hex: color)
        }
        return colors.primary
    }

    private func displayTypeBadge(_ type: String) -> some View {
        let (label, icon) = badgeInfo(for: type)

        return HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 10))
            Text(label)
                .font(.system(size: 11, weight: DesignSystem.Typography.medium))
        }
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(colors.primary.opacity(0.12))
        .foregroundColor(colors.primary)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm))
    }

    private func badgeInfo(for type: String) -> (String, String) {
        switch type {
        case "wizard":
            return ("Wizard", "wand.and.stars")
        case "decision_tree":
            return ("Decision Tree", "arrow.triangle.branch")
        case "list":
            return ("List", "list.bullet")
        case "accordion":
            return ("Accordion", "list.dash")
        default:
            return ("Flow", "arrow.right.circle")
        }
    }
}
