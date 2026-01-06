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
        // Determine toolbar scheme based on theme background luminance
        // If background is dark, use dark scheme; if light, use light scheme
        let bgColor = colors.background

        // For now, we'll use a simple heuristic based on the colorScheme
        // If the theme has been explicitly set for dark mode, use dark
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
                    ScrollView {
                        VStack(spacing: 0) {
                            // Modern Header
                            SystemStatusHeader(
                                status: viewModel.currentStatus,
                                configuration: configuration
                            )
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                            .padding(.top, DesignSystem.Spacing.sm)
                            .padding(.bottom, onSubscribe != nil ? DesignSystem.Spacing.lg : DesignSystem.Spacing.xxl)

                            // Subscribe Button
                            if let onSubscribe = onSubscribe {
                                VStack(spacing: DesignSystem.Spacing.md) {
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
                                                Image(systemName: "bell.badge")
                                                    .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                                            }
                                            Text(isSubscribing ? "Subscribing..." : "Subscribe to Updates")
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

                                    // Error Message
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
                                .padding(.horizontal, DesignSystem.Spacing.xl)
                                .padding(.bottom, DesignSystem.Spacing.xl)
                            }

                            // Services Section
                            if !viewModel.services.isEmpty {
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md + 2) {
                                    HStack {
                                        Text("Services")
                                            .font(.system(size: DesignSystem.Typography.xl, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, DesignSystem.Spacing.xl)

                                    LazyVStack(spacing: DesignSystem.Spacing.sm) {
                                        ForEach(viewModel.services) { service in
                                            StatusServiceRow(
                                                service: service,
                                                status: viewModel.overview?.servicesStatus[service.id]
                                            )
                                        }
                                    }
                                    .padding(.horizontal, DesignSystem.Spacing.xl)
                                }
                                .padding(.bottom, DesignSystem.Spacing.xxl)
                            }

                            // Updates Section
                            if !viewModel.activeUpdates.isEmpty {
                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md + 2) {
                                    HStack {
                                        Text("Recent Incidents")
                                            .font(.system(size: DesignSystem.Typography.xl, weight: .semibold))
                                            .foregroundColor(.primary)
                                        Spacer()
                                    }
                                    .padding(.horizontal, DesignSystem.Spacing.xl)

                                    LazyVStack(spacing: DesignSystem.Spacing.sm) {
                                        ForEach(Array(viewModel.activeUpdates.enumerated()), id: \.element.id) { index, update in
                                            StatusUpdateCard(
                                                update: update,
                                                configuration: configuration,
                                                isFirst: index == 0
                                            )
                                        }
                                    }
                                    .padding(.horizontal, DesignSystem.Spacing.xl)
                                }
                                .padding(.bottom, DesignSystem.Spacing.xxl)
                            }

                            // Empty State
                            if viewModel.services.isEmpty && viewModel.activeUpdates.isEmpty {
                                VStack(spacing: DesignSystem.Spacing.lg) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 64))
                                        .foregroundColor(.green)
                                    Text("All Systems Operational")
                                        .font(.system(size: DesignSystem.Typography.xxl, weight: .bold, design: .rounded))
                                    Text("Everything is running smoothly")
                                        .font(.system(size: DesignSystem.Typography.base))
                                        .foregroundColor(.secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, DesignSystem.Spacing.xxxl)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.refresh()
                    }
                }
            }
            .background(colors.background)
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
}
