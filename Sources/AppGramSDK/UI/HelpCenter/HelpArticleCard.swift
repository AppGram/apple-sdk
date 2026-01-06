import SwiftUI

public struct HelpArticleCard: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let article: HelpArticle

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(article: HelpArticle) {
        self.article = article
    }

    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs + 2) {
                Text(article.title)
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                    .foregroundColor(colors.cardText)
                    .lineLimit(2)

                if let excerpt = article.excerpt, !excerpt.isEmpty {
                    Text(excerpt)
                        .font(.system(size: DesignSystem.Typography.xs))
                        .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.muted))
                        .lineLimit(2)
                } else {
                    Text(contentPreview)
                        .font(.system(size: DesignSystem.Typography.xs))
                        .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.muted))
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: DesignSystem.Typography.xs))
                .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.disabled))
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg - 2))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg - 2)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
        .cardHoverEffect()
    }

    private var contentPreview: String {
        // Strip HTML tags for preview
        let stripped = article.content
            .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
            .replacingOccurrences(of: "&nbsp;", with: " ")
            .replacingOccurrences(of: "&amp;", with: "&")
            .replacingOccurrences(of: "&lt;", with: "<")
            .replacingOccurrences(of: "&gt;", with: ">")
            .replacingOccurrences(of: "&quot;", with: "\"")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return String(stripped.prefix(100))
    }
}
