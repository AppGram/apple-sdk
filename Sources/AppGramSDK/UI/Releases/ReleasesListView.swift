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
                    ScrollView {
                        LazyVStack(spacing: DesignSystem.Spacing.xl) {
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
                        .padding(DesignSystem.Spacing.xl)
                    }
                    .background(colors.background)
                    .navigationDestination(item: $viewModel.selectedRelease) { release in
                        ReleaseDetailView(
                            release: release,
                            configuration: configuration
                        )
                    }
                }
            }
            .navigationTitle(configuration.title)
            .navigationBarTitleDisplayMode(.large)
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
}
