import SwiftUI

struct ReleaseFeatureCard: View {
    let feature: ReleaseFeature
    let configuration: ReleasesConfiguration

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let imageUrl = feature.imageUrl, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(colors.border.opacity(DesignSystem.Opacity.muted))
                            .frame(height: 180)
                            .overlay(
                                ProgressView()
                                    .tint(colors.primary)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 180)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(colors.border.opacity(DesignSystem.Opacity.muted))
                            .frame(height: 180)
                            .overlay(
                                VStack(spacing: DesignSystem.Spacing.sm) {
                                    Image(systemName: "photo.on.rectangle.angled")
                                        .font(.system(size: DesignSystem.Typography.xxl + 4))
                                        .foregroundColor(colors.secondary.opacity(DesignSystem.Opacity.muted))
                                    Text("Image unavailable")
                                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                                        .foregroundColor(colors.secondary.opacity(DesignSystem.Opacity.muted))
                                }
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: configuration.imageCornerRadius))
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: DesignSystem.Typography.base))
                        .foregroundColor(colors.accent)

                    Text(feature.title)
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.text)
                        .fixedSize(horizontal: false, vertical: true)
                }

                if let description = feature.description {
                    Text(description)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.cardText)
                        .lineLimit(4)
                        .multilineTextAlignment(.leading)
                }
            }
            .padding(DesignSystem.Spacing.md + 2)
        }
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: configuration.cardCornerRadius))
        .overlay(
            RoundedRectangle(cornerRadius: configuration.cardCornerRadius)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
    }
}
