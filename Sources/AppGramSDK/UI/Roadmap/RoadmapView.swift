import SwiftUI

public struct RoadmapView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel: RoadmapViewModel

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(roadmapService: RoadmapServiceProtocol) {
        _viewModel = State(initialValue: RoadmapViewModel(roadmapService: roadmapService))
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Roadmap")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        layoutPicker
                    }
                }
        }
        .task {
            await viewModel.loadRoadmap()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            LoadingView()
        } else if let error = viewModel.error {
            ErrorView(error: error) {
                await viewModel.loadRoadmap()
            }
        } else if viewModel.items.isEmpty {
            EmptyStateView(
                icon: "map",
                title: "No Roadmap Items",
                message: "Check back later to see what's planned!"
            )
        } else {
            layoutContent
                .refreshable {
                    await viewModel.refresh()
                }
        }
    }

    @ViewBuilder
    private var layoutContent: some View {
        switch viewModel.selectedLayout {
        case .kanban:
            RoadmapKanbanView(columns: viewModel.filteredColumns)
        case .list:
            RoadmapListView(items: viewModel.filteredItems)
        case .timeline:
            RoadmapTimelineView(items: viewModel.timelineItems)
        }
    }

    private var layoutPicker: some View {
        Menu {
            ForEach(RoadmapLayout.allCases, id: \.self) { layout in
                Button {
                    viewModel.selectedLayout = layout
                } label: {
                    Label(layout.displayName, systemImage: layout.systemImageName)
                }
            }
        } label: {
            Image(systemName: viewModel.selectedLayout.systemImageName)
                .foregroundColor(colors.primary)
                .font(.system(size: DesignSystem.Typography.lg))
        }
    }
}
