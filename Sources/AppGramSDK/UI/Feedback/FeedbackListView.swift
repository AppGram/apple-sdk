import SwiftUI

public struct FeedbackListView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel: FeedbackViewModel
    @State private var showingSubmitSheet = false
    @State private var selectedWish: Wish?

    private let feedbackService: FeedbackServiceProtocol
    private let strings: FeedbackStrings

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(feedbackService: FeedbackServiceProtocol, strings: FeedbackStrings = .default) {
        self.feedbackService = feedbackService
        self.strings = strings
        _viewModel = State(initialValue: FeedbackViewModel(feedbackService: feedbackService))
    }

    public var body: some View {
        NavigationStack {
            content
                .navigationTitle(strings.feedbackTitle)
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            showingSubmitSheet = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(colors.primary)
                        }
                        .accessibilityLabel(strings.submitButtonLabel)
                        .accessibilityHint("Opens the feedback form.")
                    }
                }
                .searchable(
                    text: $viewModel.searchQuery,
                    prompt: strings.searchPlaceholder
                )
                .sheet(isPresented: $showingSubmitSheet) {
                    FeedbackSubmissionView(
                        feedbackService: viewModel,
                        categories: viewModel.categories,
                        strings: strings
                    ) {
                        showingSubmitSheet = false
                    }
                }
                .sheet(item: $selectedWish) { wish in
                    NavigationStack {
                        FeedbackDetailView(
                            wish: wish,
                            feedbackService: feedbackService,
                            strings: strings
                        )
                    }
                }
        }
        .task {
            await viewModel.loadCategories()
            await viewModel.loadWishes()
        }
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.wishes.isEmpty {
            LoadingView()
        } else if let error = viewModel.error, viewModel.wishes.isEmpty {
            ErrorView(error: error) {
                await viewModel.loadWishes()
            }
        } else if viewModel.wishes.isEmpty {
            EmptyStateView(
                icon: "lightbulb",
                title: strings.emptyTitle,
                message: strings.emptyMessage,
                actionTitle: strings.emptyActionLabel
            ) {
                showingSubmitSheet = true
            }
        } else {
            feedbackList
        }
    }

    private var feedbackList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                filterBar

                ForEach(viewModel.wishes) { wish in
                    FeedbackCardView(
                        wish: wish,
                        onVote: { await viewModel.vote(on: wish) },
                        onRemoveVote: { await viewModel.removeVote(from: wish) }
                    )
                    .contentShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                    .onTapGesture {
                        selectedWish = wish
                    }
                    .accessibilityAddTraits(.isButton)
                    .accessibilityHint("Opens feedback details.")
                    .accessibilityAction {
                        selectedWish = wish
                    }
                    .onAppear {
                        if wish.id == viewModel.wishes.last?.id {
                            Task { await viewModel.loadMoreWishes() }
                        }
                    }
                }

                if viewModel.isLoadingMore {
                    ProgressView()
                        .padding(DesignSystem.Spacing.md)
                        .accessibilityLabel("Loading more feedback.")
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
        .scrollIndicators(.hidden)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                Menu {
                    Button(strings.allStatusesLabel) {
                        viewModel.selectedStatus = nil
                    }
                    ForEach(WishStatus.allCases, id: \.self) { status in
                        Button(status.displayName) {
                            viewModel.selectedStatus = status
                        }
                    }
                } label: {
                    FilterChip(
                        title: viewModel.selectedStatus?.displayName ?? strings.statusFilterLabel,
                        isActive: viewModel.selectedStatus != nil,
                        minWidth: 100
                    )
                }

                if !viewModel.categories.isEmpty {
                    Menu {
                        Button(strings.allCategoriesLabel) {
                            viewModel.selectedCategory = nil
                        }
                        ForEach(viewModel.categories) { category in
                            Button(category.name) {
                                viewModel.selectedCategory = category
                            }
                        }
                    } label: {
                        FilterChip(
                            title: viewModel.selectedCategory?.name ?? strings.categoryFilterLabel,
                            isActive: viewModel.selectedCategory != nil,
                            minWidth: 120
                        )
                    }
                }

                Menu {
                    ForEach(WishSortOption.allCases, id: \.self) { option in
                        Button(option.displayName) {
                            viewModel.sortBy = option
                        }
                    }
                } label: {
                    FilterChip(
                        title: "\(strings.sortPrefix): \(viewModel.sortBy.displayName)",
                        isActive: viewModel.sortBy != .newest,
                        minWidth: 140
                    )
                }
            }
        }
    }

}

struct FilterChip: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let title: String
    let isActive: Bool
    var minWidth: CGFloat = 80

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Text(title)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                .fixedSize(horizontal: true, vertical: false)
            Image(systemName: "chevron.down")
                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.medium))
        }
        .foregroundColor(isActive ? .white : colors.text)
        .padding(.horizontal, DesignSystem.Spacing.md)
        .padding(.vertical, DesignSystem.Spacing.sm)
        .frame(minWidth: minWidth)
        .background(isActive ? colors.primary : colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.pill)
                .strokeBorder(isActive ? colors.primary : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
        .accessibilityLabel(title)
        .accessibilityValue(isActive ? "Selected" : "Not selected")
        .accessibilityHint("Opens filter options.")
        .accessibilityAddTraits(.isButton)
        .animation(DesignSystem.Animation.spring, value: isActive)
    }
}
