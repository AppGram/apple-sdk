import SwiftUI

/// Category badge with shadcn-inspired minimal styling.
///
/// ## Example
/// ```swift
/// CategoryBadge(category: category)
/// ```
public struct CategoryBadge: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let category: Category

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private var categoryColor: Color {
        if let hexColor = category.color {
            return Color(hex: hexColor)
        }
        return colors.secondary
    }

    public init(category: Category) {
        self.category = category
    }

    public var body: some View {
        Text(category.name)
            .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.medium))
            .foregroundColor(categoryColor)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, DesignSystem.Spacing.xs)
            .background(categoryColor.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                    .strokeBorder(categoryColor.opacity(0.2), lineWidth: DesignSystem.BorderWidth.hairline)
            )
    }
}
