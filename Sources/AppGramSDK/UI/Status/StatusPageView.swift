import SwiftUI

public struct StatusPageView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel: StatusViewModel
    private let configuration: StatusConfiguration
    private let onSubscribe: (() async throws -> Void)?
    private let onDismiss: (() -> Void)?

    @State private var isSubscribing = false
    @State private var subscribeError: String?

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private var toolbarScheme: ColorScheme {
        if colorScheme == .dark {
            return .dark
        } else {
            return .light
        }
    }

    public init(
        projectId: String,
        slug: String = "status",
        apiBaseURL: String,
        apiKey: String? = nil,
        configuration: StatusConfiguration = .default,
        notificationManager: NotificationManager? = nil,
        onSubscribe: (() async throws -> Void)? = nil,
        onDismiss: (() -> Void)? = nil
    ) {
        let client = APIClient(baseURL: apiBaseURL, projectId: projectId, apiKey: apiKey)
        let service = StatusService(apiClient: client)
        _viewModel = StateObject(wrappedValue: StatusViewModel(
            service: service,
            projectId: projectId,
            slug: slug,
            autoRefreshInterval: configuration.autoRefreshInterval,
            isAutoRefreshEnabled: configuration.enableAutoRefresh,
            notificationManager: notificationManager
        ))
        self.configuration = configuration
        self.onSubscribe = onSubscribe
        self.onDismiss = onDismiss
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                Group {
                    if viewModel.isLoading && viewModel.overview == nil {
                        LoadingView()
                    } else if let error = viewModel.error {
                        ErrorView(
                            error: error as? AppGramError ?? .invalidResponse,
                            retryAction: {
                                await viewModel.loadOverview()
                            }
                        )
                    } else {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: DesignSystem.Spacing.xl) {
                                headerSection
                                summaryStrip

                                if let onSubscribe = onSubscribe {
                                    subscribeSection(onSubscribe)
                                }

                                if !viewModel.services.isEmpty {
                                    sectionHeader(title: "Services", subtitle: "Live health across \(viewModel.services.count) services")
                                    servicesGrid
                                }

                                if !viewModel.activeUpdates.isEmpty {
                                    sectionHeader(title: "Incidents", subtitle: "\(viewModel.activeUpdates.count) active updates")
                                    incidentsTimeline
                                }

                                if viewModel.services.isEmpty && viewModel.activeUpdates.isEmpty {
                                    emptyStateView
                                }
                            }
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                            .padding(.top, DesignSystem.Spacing.lg)
                            .padding(.bottom, DesignSystem.Spacing.xxxl)
                        }
                        .refreshable {
                            await viewModel.refresh()
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        onDismiss?()
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                    }
                }
                ToolbarItem(placement: .title) {
                    Text(configuration.title)
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                }
            }
            .toolbarColorScheme(toolbarScheme, for: .navigationBar)
        }
        .task {
            await viewModel.loadOverview()
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
                .frame(width: 280, height: 280)
                .offset(x: -160, y: -140)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 140)
                .fill(colors.neutral200.opacity(0.2))
                .frame(width: 260, height: 160)
                .rotationEffect(.degrees(-12))
                .offset(x: 120, y: 120)
        )
        .ignoresSafeArea()
    }

    private var headerSection: some View {
        let statusPage = viewModel.overview?.statusPage
        let description = statusPage?.description?.trimmingCharacters(in: .whitespacesAndNewlines)
        let updatedAt = statusPage?.updatedAt

        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                    Text("Current status")
                        .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                        .foregroundColor(colors.neutral500)

                    Text(viewModel.currentStatus.displayName)
                        .font(.system(size: DesignSystem.Typography.xxxl, weight: .bold, design: .rounded))
                        .foregroundColor(colors.text)
                        .minimumScaleFactor(0.8)
                }

                Spacer()

                StatusTypeBadge(statusType: viewModel.currentStatus)
            }

            if let description, !description.isEmpty {
                Text(description)
                    .font(.system(size: DesignSystem.Typography.base))
                    .foregroundColor(colors.neutral500)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let updatedAt = updatedAt {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: DesignSystem.Typography.xs, weight: .semibold))
                    Text("Updated \(updatedAt, style: .relative)")
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
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(viewModel.currentStatus.color)
                .frame(width: 4)
                .padding(.vertical, DesignSystem.Spacing.lg)
                .offset(x: 2)
        }
        .layeredShadow()
    }

    private var summaryStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.md) {
                statCard(
                    title: "Services",
                    value: "\(viewModel.services.count)",
                    icon: "server.rack",
                    tint: colors.primary
                )

                statCard(
                    title: "Active updates",
                    value: "\(viewModel.activeUpdates.count)",
                    icon: "exclamationmark.bubble",
                    tint: colors.warning
                )

                statCard(
                    title: "Auto refresh",
                    value: viewModel.isAutoRefreshEnabled ? "On" : "Off",
                    icon: "timer",
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

    private var servicesGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DesignSystem.Spacing.md) {
            ForEach(viewModel.services) { service in
                StatusServiceRow(
                    service: service,
                    status: viewModel.overview?.servicesStatus?[service.id]
                )
            }
        }
    }

    private var incidentsTimeline: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(Array(viewModel.activeUpdates.enumerated()), id: \.element.id) { index, update in
                StatusUpdateCard(
                    update: update,
                    configuration: configuration,
                    isFirst: index == 0
                )
            }
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 64))
                .foregroundColor(colors.success)

            Text("All Systems Operational")
                .font(.system(size: DesignSystem.Typography.xxl, weight: .bold, design: .rounded))
                .foregroundColor(colors.text)

            Text("Everything is running smoothly")
                .font(.system(size: DesignSystem.Typography.base))
                .foregroundColor(colors.neutral500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignSystem.Spacing.xxxl)
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

    private func subscribeSection(_ onSubscribe: @escaping () async throws -> Void) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack(spacing: DesignSystem.Spacing.md) {
                ZStack {
                    Circle()
                        .fill(colors.primary.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "bell.badge")
                        .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                        .foregroundColor(colors.primary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Get alerts")
                        .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                        .foregroundColor(colors.text)
                    Text("Receive updates when incidents change.")
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.neutral500)
                }

                Spacer()
            }

            Button(action: {
                Task {
                    isSubscribing = true
                    subscribeError = nil
                    do {
                        try await onSubscribe()
                    } catch {
                        subscribeError = error.localizedDescription
                    }
                    isSubscribing = false
                }
            }) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    if isSubscribing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: DesignSystem.Typography.xs, weight: .semibold))
                    }
                    Text(isSubscribing ? "Subscribing..." : "Notify me")
                        .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.md + 2)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                        .fill(isSubscribing ? colors.primary.opacity(DesignSystem.Opacity.disabled) : colors.primary)
                )
            }
            .disabled(isSubscribing)

            if let error = subscribeError {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: DesignSystem.Typography.xs))
                    Text(error)
                        .font(.system(size: DesignSystem.Typography.sm))
                }
                .foregroundColor(colors.error)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs + 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                        .fill(colors.error.opacity(0.1))
                )
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground.opacity(0.9), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }
}
