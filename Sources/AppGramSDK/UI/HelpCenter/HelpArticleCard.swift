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
                        .foregroundColor(colors.neutral500)
                        .lineLimit(2)
                } else {
                    Text(contentPreview)
                        .font(.system(size: DesignSystem.Typography.xs))
                        .foregroundColor(colors.neutral500)
                        .lineLimit(2)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: DesignSystem.Typography.xs))
                .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.disabled))
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg - 2))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg - 2)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(colors.primary)
                .frame(width: 3)
                .padding(.vertical, DesignSystem.Spacing.md)
                .offset(x: 2)
        }
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
