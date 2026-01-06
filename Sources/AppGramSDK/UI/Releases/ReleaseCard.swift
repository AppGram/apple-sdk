import SwiftUI

struct ReleaseCard: View {
    let release: Release
    let configuration: ReleasesConfiguration
    let onTap: () -> Void

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                if let coverImageUrl = release.coverImageUrl, let url = URL(string: coverImageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(colors.border.opacity(0.3))
                                .frame(height: 200)
                                .overlay(
                                    ProgressView()
                                        .tint(colors.primary)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 200)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(colors.border.opacity(0.3))
                                .frame(height: 200)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: 32))
                                            .foregroundColor(colors.secondary.opacity(0.6))
                                        Text("Image unavailable")
                                            .font(.caption)
                                            .foregroundColor(colors.secondary.opacity(0.6))
                                    }
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: configuration.imageCornerRadius))
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                        Text(release.title)
                            .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        Spacer(minLength: DesignSystem.Spacing.sm)

                        if configuration.showVersionBadge, let version = release.version {
                            Text(version)
                                .font(.system(size: DesignSystem.Typography.xs - 1, weight: DesignSystem.Typography.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, DesignSystem.Spacing.sm + 2)
                                .padding(.vertical, DesignSystem.Spacing.xs + 1)
                                .background(
                                    LinearGradient(
                                        colors: [colors.primary, colors.primary.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: colors.primary.opacity(0.3), radius: DesignSystem.Shadow.xs.radius, y: DesignSystem.Shadow.xs.y)
                        }
                    }

                    if !release.labels.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                ForEach(release.labels, id: \.self) { label in
                                    ReleaseLabelBadge(label: label)
                                }
                            }
                        }
                    }

                    if let excerpt = release.excerpt {
                        Text(excerpt)
                            .font(.system(size: DesignSystem.Typography.sm))
                            .foregroundColor(colors.cardText)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                    }

                    if let publishedAt = release.publishedAt {
                        HStack(spacing: DesignSystem.Spacing.xs + 2) {
                            Image(systemName: "calendar")
                                .font(.system(size: DesignSystem.Typography.xs - 1))
                            Text(publishedAt, style: .date)
                                .font(.system(size: DesignSystem.Typography.xs))
                        }
                        .foregroundColor(colors.secondary)
                        .padding(.top, DesignSystem.Spacing.xs)
                    }
                }
                .padding(DesignSystem.Spacing.lg)
            }
            .background(colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: configuration.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: configuration.cardCornerRadius)
                    .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
            )
            .layeredShadow()
        }
        .buttonStyle(.plain)
        .cardHoverEffect()
    }
}
