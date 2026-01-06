import SwiftUI

public struct HelpCenterView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel: HelpViewModel
    @State private var selectedCollection: HelpCollection?
    @State private var selectedFlow: HelpFlow?
    @State private var selectedArticle: HelpArticle?
    @State private var wizardViewModel: WizardViewModel?
    @State private var decisionTreeViewModel: DecisionTreeViewModel?
    @State private var articleSheet: HelpArticle?
    
    private let configuration: HelpCenterConfiguration

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        helpService: HelpServiceProtocol,
        configuration: HelpCenterConfiguration = .default
    ) {
        _viewModel = State(initialValue: HelpViewModel(helpService: helpService))
        self.configuration = configuration
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle("Help Center")
                .searchable(
                    text: $viewModel.searchQuery,
                    prompt: "Search articles..."
                )
                .navigationDestination(item: $selectedCollection) { collection in
                    collectionDetailView(collection)
                }
                .navigationDestination(item: $selectedFlow) { flow in
                    flowDetailView(flow)
                }
                .navigationDestination(item: $selectedArticle) { article in
                    HelpArticleDetailView(article: article)
                }
                .sheet(item: $articleSheet) { article in
                    NavigationStack {
                        HelpArticleDetailView(article: article)
                            .navigationTitle(article.title)
                            .navigationBarTitleDisplayMode(.inline)
                        #if os(iOS)
                            .toolbar {
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    Button("Done") {
                                        articleSheet = nil
                                    }
                                }
                            }
                        #endif
                    }
                }
        }
        .task {
            await viewModel.loadCollections()
        }
        .onChange(of: selectedFlow) { oldValue, newValue in
            // Reset view models when flow changes
            if let flow = newValue {
                // Initialize appropriate view model based on display type
                if flow.displayType == "wizard" {
                    let vm = WizardViewModel()
                    vm.loadFlow(flow)
                    wizardViewModel = vm
                    decisionTreeViewModel = nil
                } else if flow.displayType == "decision_tree" {
                    let vm = DecisionTreeViewModel()
                    vm.loadFlow(flow)
                    decisionTreeViewModel = vm
                    wizardViewModel = nil
                } else {
                    wizardViewModel = nil
                    decisionTreeViewModel = nil
                }
            } else {
                wizardViewModel?.reset()
                wizardViewModel = nil
                decisionTreeViewModel?.reset()
                decisionTreeViewModel = nil
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            LoadingView()
        } else if let error = viewModel.error {
            ErrorView(error: error) {
                await viewModel.loadCollections()
            }
        } else if viewModel.searchQuery.isEmpty {
            collectionsView
        } else {
            searchResultsView
        }
    }

    private var collectionsView: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                // Show flows first
                ForEach(viewModel.flows) { flow in
                    HelpFlowCard(flow: flow)
                        .id("flow-\(flow.id)")
                        .onTapGesture {
                            // Initialize appropriate view model before navigation
                            if flow.displayType == "wizard" {
                                let vm = WizardViewModel()
                                vm.loadFlow(flow)
                                wizardViewModel = vm
                                decisionTreeViewModel = nil
                            } else if flow.displayType == "decision_tree" {
                                let vm = DecisionTreeViewModel()
                                vm.loadFlow(flow)
                                decisionTreeViewModel = vm
                                wizardViewModel = nil
                            } else {
                                wizardViewModel = nil
                                decisionTreeViewModel = nil
                            }
                            selectedFlow = flow
                        }
                }

                // Then show collections (only if they're not duplicates of flows)
                // Deduplicate by checking if collection ID exists in flows
                let flowIds = Set(viewModel.flows.map { $0.id })
                ForEach(viewModel.collections.filter { !flowIds.contains($0.id) }) { collection in
                    HelpCollectionCard(collection: collection)
                        .id("collection-\(collection.id)")
                        .onTapGesture {
                            selectedCollection = collection
                        }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var searchResultsView: some View {
        Group {
            if viewModel.filteredArticles.isEmpty {
                EmptyStateView(
                    icon: "magnifyingglass",
                    title: "No Results",
                    message: "Try a different search term"
                )
            } else {
                ScrollView {
                    LazyVStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(viewModel.filteredArticles) { article in
                            HelpArticleCard(article: article)
                                .onTapGesture {
                                    selectedArticle = article
                                }
                        }
                    }
                    .padding(DesignSystem.Spacing.lg)
                }
                .background(colors.background)
            }
        }
    }

    private func collectionDetailView(_ collection: HelpCollection) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                if let description = collection.description {
                    Text(description)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                }

                if let articles = collection.articles, !articles.isEmpty {
                    LazyVStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(articles) { article in
                            HelpArticleCard(article: article)
                                .onTapGesture {
                                    selectedArticle = article
                                }
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No Articles",
                        message: "This collection is empty"
                    )
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
        .navigationTitle(collection.name)
    }

    @ViewBuilder
    private func flowDetailView(_ flow: HelpFlow) -> some View {
        Group {
            // Check display type and render accordingly
            if flow.displayType == "wizard" {
                wizardFlowView(flow)
            } else if flow.displayType == "decision_tree" {
                decisionTreeFlowView(flow)
            } else {
                // Default flow - show articles as a list
                defaultFlowView(flow)
            }
        }
        .background(colors.background)
    }
    
    @ViewBuilder
    private func wizardFlowView(_ flow: HelpFlow) -> some View {
        Group {
            if let wizardVM = wizardViewModel {
                #if os(iOS)
                WizardFlowView(viewModel: wizardVM)
                    .navigationTitle(flow.name)
                    .navigationBarTitleDisplayMode(.inline)
                #else
                WizardFlowView(viewModel: wizardVM)
                    .navigationTitle(flow.name)
                #endif
            } else {
                // Loading state while view model initializes
                LoadingView()
                    .task {
                        let vm = WizardViewModel()
                        vm.loadFlow(flow)
                        wizardViewModel = vm
                    }
            }
        }
    }
    
    @ViewBuilder
    private func decisionTreeFlowView(_ flow: HelpFlow) -> some View {
        Group {
            if let decisionTreeVM = decisionTreeViewModel {
                #if os(iOS)
                DecisionTreeFlowView(
                    viewModel: decisionTreeVM,
                    configuration: configuration,
                    onArticleSelected: handleArticleSelection
                )
                .navigationTitle(flow.name)
                .navigationBarTitleDisplayMode(.inline)
                #else
                DecisionTreeFlowView(
                    viewModel: decisionTreeVM,
                    configuration: configuration,
                    onArticleSelected: handleArticleSelection
                )
                .navigationTitle(flow.name)
                #endif
            } else {
                // Loading state while view model initializes
                LoadingView()
                    .task {
                        let vm = DecisionTreeViewModel()
                        vm.loadFlow(flow)
                        decisionTreeViewModel = vm
                    }
            }
        }
    }
    
    private func handleArticleSelection(_ article: HelpArticle) {
        switch configuration.articleDisplayBehavior {
        case .inline:
            // Already handled inline in DecisionTreeFlowView
            break
        case .pushToStack:
            selectedArticle = article
        case .sheet:
            articleSheet = article
        case .replace:
            // Replace current flow with article
            selectedFlow = nil
            selectedArticle = article
        }
    }

    private func defaultFlowView(_ flow: HelpFlow) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                if let description = flow.description {
                    Text(description)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                }

                if let articles = flow.articles, !articles.isEmpty {
                    LazyVStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(articles.filter { $0.isPublished }) { article in
                            HelpArticleCard(article: article)
                                .padding(.horizontal, DesignSystem.Spacing.lg)
                                .onTapGesture {
                                    selectedArticle = article
                                }
                        }
                    }
                } else {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No Articles",
                        message: "This flow doesn't have any articles yet."
                    )
                    .padding(DesignSystem.Spacing.lg)
                }
            }
            .padding(.vertical, DesignSystem.Spacing.lg)
        }
        .navigationTitle(flow.name)
    }
}
