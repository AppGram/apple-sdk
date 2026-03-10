import SwiftUI

public struct ReleasesListView: View {
    @StateObject private var viewModel: ReleasesViewModel
    private let configuration: ReleasesConfiguration
    private let onDismiss: (() -> Void)?

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private var latestRelease: Release? {
        viewModel.releases.first
    }

    public init(
        orgSlug: String,
        projectSlug: String,
        apiBaseURL: String,
        apiKey: String? = nil,
        configuration: ReleasesConfiguration = .default,
        notificationManager: NotificationManager? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let client = APIClient(baseURL: apiBaseURL, projectId: "", apiKey: apiKey)
        let service = ReleasesService(apiClient: client)
        _viewModel = StateObject(wrappedValue: ReleasesViewModel(
            service: service,
            orgSlug: orgSlug,
            projectSlug: projectSlug,
            notificationManager: notificationManager
        ))
        self.configuration = configuration
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                Group {
                    if viewModel.isLoading && viewModel.releases.isEmpty {
                        LoadingView()
                    } else if let error = viewModel.error {
                        ErrorView(
                            error: error as? AppGramError ?? .invalidResponse,
                            retryAction: {
                                await viewModel.loadReleases()
                            }
                        )
                    } else if viewModel.releases.isEmpty {
                        EmptyStateView(
                            icon: "doc.text.fill",
                            title: "No Releases",
                            message: "There are no releases to display yet"
                        )
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: DesignSystem.Spacing.xl) {
                                headerSection
                                summaryStrip

                                sectionHeader(title: "Latest releases", subtitle: "Product updates and changelogs")

                                LazyVStack(spacing: DesignSystem.Spacing.lg) {
                                    ForEach(viewModel.releases) { release in
                                        ReleaseCard(
                                            release: release,
                                            configuration: configuration
                                        ) {
                                            Task {
                                                await viewModel.selectRelease(slug: release.slug)
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(DesignSystem.Spacing.xl)
                        }
                        .navigationDestination(item: $viewModel.selectedRelease) { release in
                            ReleaseDetailView(
                                release: release,
                                configuration: configuration
                            )
                        }
                    }
                }
            }
            .navigationTitle(configuration.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onDismiss?()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                    }
                }
            }
        }
        .task {
            await viewModel.loadReleases()
        }
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
                .frame(width: 260, height: 260)
                .offset(x: -140, y: -120)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 120)
                .fill(colors.neutral200.opacity(0.2))
                .frame(width: 240, height: 150)
                .rotationEffect(.degrees(-8))
                .offset(x: 140, y: 110)
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(configuration.title)
                .font(.system(size: DesignSystem.Typography.xxxl, weight: .bold, design: .rounded))
                .foregroundColor(colors.text)

            Text("Latest product updates with highlights, fixes, and improvements.")
                .font(.system(size: DesignSystem.Typography.base))
                .foregroundColor(colors.neutral500)

            if let publishedAt = latestRelease?.publishedAt {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "calendar")
                        .font(.system(size: DesignSystem.Typography.xs, weight: .semibold))
                    Text("Last update \(publishedAt, style: .relative)")
                        .font(.system(size: DesignSystem.Typography.sm))
                }
                .foregroundColor(colors.neutral500)
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                .fill(colors.cardBackground.opacity(0.95))
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
    }

    private var summaryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.md) {
                statCard(
                    title: "Total",
                    value: "\(viewModel.releases.count)",
                    icon: "sparkles",
                    tint: colors.primary
                )

                statCard(
                    title: "Latest",
                    value: latestRelease?.version ?? "New",
                    icon: "tag",
                    tint: colors.accent
                )

                statCard(
                    title: "Labels",
                    value: "\(latestRelease?.labels.count ?? 0)",
                    icon: "bookmark",
                    tint: colors.success
                )
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
        }
        .padding(.horizontal, -DesignSystem.Spacing.xl)
    }

    private func statCard(title: String, value: String, icon: String, tint: Color) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.15))
                    .frame(width: 40, height: 40)
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

    private func sectionHeader(title: String, subtitle: String) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(.system(size: DesignSystem.Typography.xl, weight: .semibold))
                    .foregroundColor(colors.text)
                Text(subtitle)
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.neutral500)
            }
            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground.opacity(0.9), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }
}
