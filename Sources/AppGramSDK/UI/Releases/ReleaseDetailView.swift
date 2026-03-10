import SwiftUI

struct ReleaseDetailView: View {
    let release: Release
    let configuration: ReleasesConfiguration

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private var accent: Color {
        release.labels.first?.color ?? colors.primary
    }

    private var timelineItems: [(String, Date, String)] {
        var items: [(String, Date, String)] = [("Drafted", release.createdAt, "Initial release notes drafted.")]

        if let publishedAt = release.publishedAt {
            items.append(("Published", publishedAt, "Release went live for customers."))
        }

        if release.updatedAt > release.createdAt {
            items.append(("Refined", release.updatedAt, "Release notes updated with the latest details."))
        }

        return items
    }

    private var storyContent: String {
        guard let content = release.content else { return "" }
        let lines = content.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        guard let firstIndex = lines.firstIndex(where: { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }) else {
            return content
        }

        let firstLine = lines[firstIndex].trimmingCharacters(in: .whitespacesAndNewlines)
        guard firstLine.hasPrefix("#") else { return content }

        let heading = firstLine.trimmingCharacters(in: CharacterSet(charactersIn: "# ")).trimmingCharacters(in: .whitespacesAndNewlines)
        guard !heading.isEmpty else { return content }

        let titleLowercased = release.title.lowercased()
        let headingLowercased = heading.lowercased()
        let shouldRemove = headingLowercased == titleLowercased
            || headingLowercased.contains(titleLowercased)
            || titleLowercased.contains(headingLowercased)

        guard shouldRemove else { return content }

        var trimmedLines = lines
        trimmedLines.remove(at: firstIndex)
        return trimmedLines.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                heroCard

                summarySection

                if let features = release.features, !features.isEmpty {
                    highlightsSection(features)
                }

                if !storyContent.isEmpty {
                    storySection(storyContent)
                }

                timelineSection
            }
            .padding(DesignSystem.Spacing.xl)
        }
        .background(backgroundView)
        .navigationTitle(release.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [colors.background, colors.neutral100],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Circle()
                .fill(colors.neutral200.opacity(0.3))
                .frame(width: 260, height: 260)
                .offset(x: 160, y: -120)
        )
        .ignoresSafeArea()
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            if let coverImageUrl = release.coverImageUrl, let url = URL(string: coverImageUrl) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(colors.border.opacity(DesignSystem.Opacity.muted))
                            .frame(height: 220)
                            .overlay(
                                ProgressView()
                                    .tint(colors.primary)
                            )
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 220)
                            .clipped()
                    case .failure:
                        Rectangle()
                            .fill(colors.border.opacity(DesignSystem.Opacity.muted))
                            .frame(height: 220)
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

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if configuration.showVersionBadge, let version = release.version {
                        Text(version)
                            .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, DesignSystem.Spacing.md)
                            .padding(.vertical, DesignSystem.Spacing.xs + 1)
                            .background(accent)
                            .clipShape(Capsule())
                    }

                    if let publishedAt = release.publishedAt {
                        HStack(spacing: DesignSystem.Spacing.xs) {
                            Image(systemName: "calendar")
                                .font(.system(size: DesignSystem.Typography.xs))
                            Text(publishedAt, style: .date)
                                .font(.system(size: DesignSystem.Typography.xs + 1))
                        }
                        .foregroundColor(colors.neutral500)
                        .padding(.horizontal, DesignSystem.Spacing.md)
                        .padding(.vertical, DesignSystem.Spacing.xs + 1)
                        .background(colors.border.opacity(DesignSystem.Opacity.subtle))
                        .clipShape(Capsule())
                    }

                    Spacer()
                }

                Text(release.title)
                    .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                    .foregroundColor(colors.text)
                    .fixedSize(horizontal: false, vertical: true)

                if let excerpt = release.excerpt {
                    Text(excerpt)
                        .font(.system(size: DesignSystem.Typography.base))
                        .foregroundColor(colors.neutral500)
                }
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                .fill(colors.cardBackground.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(accent)
                .frame(width: 4)
                .padding(.vertical, DesignSystem.Spacing.lg)
                .offset(x: 2)
        }
        .layeredShadow()
    }

    private var summarySection: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            storyStat(title: "Highlights", value: "\(release.features?.count ?? 0)", icon: "sparkles", tint: colors.primary)
            storyStat(title: "Labels", value: "\(release.labels.count)", icon: "bookmark", tint: colors.accent)
        }
    }

    private func storyStat(title: String, value: String, icon: String, tint: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                    .foregroundColor(tint)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                    .foregroundColor(colors.text)
                Text(title)
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.neutral500)
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, DesignSystem.Spacing.md)
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .fill(colors.cardBackground.opacity(0.9))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }

    private func highlightsSection(_ features: [ReleaseFeature]) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "sparkles")
                    .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                    .foregroundColor(colors.primary)
                Text("Highlights")
                    .font(.system(size: DesignSystem.Typography.lg, weight: .semibold))
                    .foregroundColor(colors.text)
            }

            ForEach(features) { feature in
                ReleaseFeatureCard(
                    feature: feature,
                    configuration: configuration
                )
            }
        }
    }

    private func storySection(_ content: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "book.closed")
                    .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                    .foregroundColor(accent)
                Text("Release story")
                    .font(.system(size: DesignSystem.Typography.lg, weight: .semibold))
                    .foregroundColor(colors.text)
            }

            MarkdownView(content)
                .foregroundColor(colors.text)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .fill(colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                    .foregroundColor(colors.warning)
                Text("Release journey")
                    .font(.system(size: DesignSystem.Typography.lg, weight: .semibold))
                    .foregroundColor(colors.text)
            }

            VStack(spacing: DesignSystem.Spacing.md) {
                ForEach(Array(timelineItems.enumerated()), id: \.offset) { index, item in
                    timelineRow(title: item.0, date: item.1, detail: item.2, isLast: index == timelineItems.count - 1)
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .fill(colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }

    private func timelineRow(title: String, date: Date, detail: String, isLast: Bool) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            VStack(spacing: 0) {
                Circle()
                    .fill(accent)
                    .frame(width: 8, height: 8)
                    .padding(.top, 4)

                if !isLast {
                    Rectangle()
                        .fill(colors.border)
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                        .opacity(0.6)
                }
            }
            .frame(width: 16)

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                    .foregroundColor(colors.text)

                Text(date, style: .date)
                    .font(.system(size: DesignSystem.Typography.xs))
                    .foregroundColor(colors.neutral500)

                Text(detail)
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.neutral500)
            }

            Spacer(minLength: 0)
        }
    }
}
