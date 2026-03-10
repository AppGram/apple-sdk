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

    private var accent: Color {
        release.labels.first?.color ?? colors.primary
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                if let coverImageUrl = release.coverImageUrl, let url = URL(string: coverImageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(colors.border.opacity(0.3))
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
                                .fill(colors.border.opacity(0.3))
                                .frame(height: 180)
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

                HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        Text(release.title)
                            .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)

                        if let excerpt = release.excerpt {
                            Text(excerpt)
                                .font(.system(size: DesignSystem.Typography.sm))
                                .foregroundColor(colors.neutral500)
                                .lineLimit(3)
                        }
                    }

                    Spacer(minLength: DesignSystem.Spacing.sm)

                    if configuration.showVersionBadge, let version = release.version {
                        Text(version)
                            .font(.system(size: DesignSystem.Typography.xs - 1, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, DesignSystem.Spacing.sm + 2)
                            .padding(.vertical, DesignSystem.Spacing.xs + 1)
                            .background(accent)
                            .clipShape(Capsule())
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

                if let publishedAt = release.publishedAt {
                    HStack(spacing: DesignSystem.Spacing.xs + 2) {
                        Image(systemName: "calendar")
                            .font(.system(size: DesignSystem.Typography.xs - 1))
                        Text(publishedAt, style: .date)
                            .font(.system(size: DesignSystem.Typography.xs))
                    }
                    .foregroundColor(colors.neutral500)
                    .padding(.top, DesignSystem.Spacing.xs)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .background(colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: configuration.cardCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: configuration.cardCornerRadius)
                    .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
            )
            .overlay(alignment: .leading) {
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                    .fill(accent)
                    .frame(width: 3)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .offset(x: 2)
            }
            .layeredShadow()
        }
        .buttonStyle(.plain)
        .cardHoverEffect()
    }
}
