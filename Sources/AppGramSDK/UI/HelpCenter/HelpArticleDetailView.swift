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
        ZStack {
            backgroundView

            ScrollView {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    headerCard

                    HTMLContentView(
                        htmlContent: article.content,
                        textColor: colors.text,
                        backgroundColor: colors.cardBackground
                    )
                    .padding(DesignSystem.Spacing.lg)
                    .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                    )
                }
                .padding(DesignSystem.Spacing.lg)
            }
        }
        .navigationTitle("Article")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(article.title)
                .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                .foregroundColor(colors.text)

            if let excerpt = article.excerpt, !excerpt.isEmpty {
                Text(excerpt)
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.neutral500)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let updatedAt = article.updatedAt {
                Text("Last updated: \(formattedDate(updatedAt))")
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.neutral500)
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [colors.background, colors.neutral100],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Circle()
                .fill(colors.neutral200.opacity(0.35))
                .frame(width: 240, height: 240)
                .offset(x: 140, y: -140)
        )
        .ignoresSafeArea()
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
