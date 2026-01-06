import SwiftUI

struct ReleaseDetailView: View {
    let release: Release
    let configuration: ReleasesConfiguration

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if let coverImageUrl = release.coverImageUrl, let url = URL(string: coverImageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(colors.border.opacity(DesignSystem.Opacity.muted))
                                .frame(height: 280)
                                .overlay(
                                    ProgressView()
                                        .tint(colors.primary)
                                )
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(height: 280)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(colors.border.opacity(DesignSystem.Opacity.muted))
                                .frame(height: 280)
                                .overlay(
                                    VStack(spacing: DesignSystem.Spacing.md) {
                                        Image(systemName: "photo.on.rectangle.angled")
                                            .font(.system(size: DesignSystem.Typography.xxxl - 4))
                                            .foregroundColor(colors.secondary.opacity(DesignSystem.Opacity.muted))
                                        Text("Image unavailable")
                                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                                            .foregroundColor(colors.secondary.opacity(DesignSystem.Opacity.muted))
                                    }
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .clipShape(RoundedRectangle(cornerRadius: configuration.imageCornerRadius))
                }

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        if configuration.showVersionBadge, let version = release.version {
                            Text(version)
                                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, DesignSystem.Spacing.md)
                                .padding(.vertical, DesignSystem.Spacing.xs + 1)
                                .background(
                                    LinearGradient(
                                        colors: [colors.primary, colors.primary.opacity(0.8)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadowStyle(DesignSystem.Shadow.xs)
                        }

                        if let publishedAt = release.publishedAt {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "calendar")
                                    .font(.system(size: DesignSystem.Typography.xs))
                                Text(publishedAt, style: .date)
                                    .font(.system(size: DesignSystem.Typography.xs + 1))
                            }
                            .foregroundColor(colors.secondary)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.xs + 1)
                            .background(colors.border.opacity(DesignSystem.Opacity.subtle))
                            .clipShape(Capsule())
                        }

                        Spacer()
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

                    if let content = release.content {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Divider()
                                .background(colors.border)

                            MarkdownView(content)
                                .foregroundColor(colors.text)
                        }
                    }

                    if let features = release.features, !features.isEmpty {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                            Divider()
                                .background(colors.border)

                            HStack {
                                Image(systemName: "star.circle.fill")
                                    .font(.system(size: DesignSystem.Typography.xl))
                                    .foregroundColor(colors.primary)
                                Text("Features")
                                    .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.bold))
                                    .foregroundColor(colors.text)
                            }

                            ForEach(features) { feature in
                                ReleaseFeatureCard(
                                    feature: feature,
                                    configuration: configuration
                                )
                            }
                        }
                        .padding(.top, DesignSystem.Spacing.sm)
                    }
                }
                .padding(DesignSystem.Spacing.xl)
            }
        }
        .background(colors.background)
        .navigationTitle(release.title)
        .navigationBarTitleDisplayMode(.large)
    }
}
