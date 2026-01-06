import SwiftUI

public struct HelpArticleDetailView: View {
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
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                Text(article.title)
                    .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                    .foregroundColor(colors.text)

                if let excerpt = article.excerpt, !excerpt.isEmpty {
                    Text(excerpt)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let updatedAt = article.updatedAt {
                    Text("Last updated: \(formattedDate(updatedAt))")
                        .font(.system(size: DesignSystem.Typography.xs))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.disabled))
                }

                Divider()

                HTMLContentView(
                    htmlContent: article.content,
                    textColor: colors.text,
                    backgroundColor: colors.background
                )
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
