import SwiftUI

public struct HelpCollectionCard: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let collection: HelpCollection

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(collection: HelpCollection) {
        self.collection = collection
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                if let icon = collection.icon {
                    Image(systemName: icon)
                        .font(.system(size: DesignSystem.Typography.xxl))
                        .foregroundColor(colors.primary)
                } else {
                    Image(systemName: "folder")
                        .font(.system(size: DesignSystem.Typography.xxl))
                        .foregroundColor(colors.primary)
                }

                Text(collection.name)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.cardText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.disabled))
            }

            if let description = collection.description {
                Text(description)
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.muted))
                    .lineLimit(2)
            }

            if let articles = collection.articles {
                Text("\(articles.count) article\(articles.count == 1 ? "" : "s")")
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.disabled))
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }
}
