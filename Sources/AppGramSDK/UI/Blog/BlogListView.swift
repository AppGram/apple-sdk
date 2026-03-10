import SwiftUI

/// A view displaying a list of blog posts with pagination and filtering.
public struct BlogListView: View {
    @State private var viewModel: BlogViewModel
    @State private var searchText = ""
    @State private var selectedCategorySlug: String?

    let onPostTap: ((BlogPost) -> Void)?

    @Environment(\.appGramTheme) private var theme

    public init(
        blogService: BlogServiceProtocol,
        onPostTap: ((BlogPost) -> Void)? = nil
    ) {
        self._viewModel = State(initialValue: BlogViewModel(blogService: blogService))
        self.onPostTap = onPostTap
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(theme.colors.neutral500)

                TextField("Search posts...", text: $searchText)
                    .textFieldStyle(.plain)
                    .submitLabel(.search)
                    .onSubmit {
                        Task {
                            await viewModel.search(query: searchText)
                        }
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        Task {
                            await viewModel.loadPosts(resetPage: true)
                        }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(theme.colors.neutral500)
                    }
                }
            }
            .padding(12)
            .background(theme.colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding(.horizontal)
            .padding(.top)

            // Categories
            if !viewModel.categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        CategoryChip(
                            name: "All",
                            isSelected: selectedCategorySlug == nil,
                            theme: theme
                        ) {
                            selectedCategorySlug = nil
                            Task {
                                await viewModel.filterByCategory(nil)
                            }
                        }

                        ForEach(viewModel.categories, id: \.id) { category in
                            CategoryChip(
                                name: category.name,
                                isSelected: selectedCategorySlug == category.slug,
                                theme: theme
                            ) {
                                selectedCategorySlug = category.slug
                                Task {
                                    await viewModel.filterByCategory(category.slug)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 12)
            }

            // Content
            if viewModel.isLoading && viewModel.posts.isEmpty {
                Spacer()
                ProgressView()
                    .tint(theme.colors.primary)
                Spacer()
            } else if let error = viewModel.error {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.largeTitle)
                        .foregroundStyle(theme.colors.error)

                    Text("Failed to load posts")
                        .font(.headline)
                        .foregroundStyle(theme.colors.text)

                    Text(error.localizedDescription)
                        .font(.subheadline)
                        .foregroundStyle(theme.colors.neutral500)
                        .multilineTextAlignment(.center)

                    Button("Try Again") {
                        Task {
                            await viewModel.loadPosts(resetPage: true)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(theme.colors.primary)
                }
                .padding()
                Spacer()
            } else if viewModel.posts.isEmpty {
                Spacer()
                VStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .font(.largeTitle)
                        .foregroundStyle(theme.colors.neutral500)

                    Text("No posts found")
                        .font(.headline)
                        .foregroundStyle(theme.colors.text)

                    Text("Try a different search or filter")
                        .font(.subheadline)
                        .foregroundStyle(theme.colors.neutral500)
                }
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewModel.posts, id: \.id) { post in
                            BlogPostCard(post: post) {
                                onPostTap?(post)
                            }
                        }

                        // Pagination
                        if viewModel.totalPages > 1 {
                            PaginationView(
                                currentPage: viewModel.currentPage,
                                totalPages: viewModel.totalPages,
                                isLoading: viewModel.isLoading,
                                onPageChange: { page in
                                    Task {
                                        await viewModel.goToPage(page)
                                    }
                                }
                            )
                            .padding(.vertical)
                        }
                    }
                    .padding()
                }
                .refreshable {
                    await viewModel.loadPosts(resetPage: true)
                }
            }
        }
        .background(theme.colors.background)
        .task {
            await viewModel.loadCategories()
            await viewModel.loadPosts(resetPage: true)
        }
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let name: String
    let isSelected: Bool
    let theme: AppGramTheme
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundStyle(isSelected ? .white : theme.colors.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? theme.colors.primary : theme.colors.cardBackground)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.clear : theme.colors.border, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Pagination View

private struct PaginationView: View {
    let currentPage: Int
    let totalPages: Int
    let isLoading: Bool
    let onPageChange: (Int) -> Void

    @Environment(\.appGramTheme) private var theme

    var body: some View {
        HStack(spacing: 12) {
            Button {
                onPageChange(currentPage - 1)
            } label: {
                Image(systemName: "chevron.left")
                    .font(.body.weight(.semibold))
            }
            .disabled(currentPage <= 1 || isLoading)

            Text("Page \(currentPage) of \(totalPages)")
                .font(.subheadline)
                .foregroundStyle(theme.colors.neutral500)

            Button {
                onPageChange(currentPage + 1)
            } label: {
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
            }
            .disabled(currentPage >= totalPages || isLoading)
        }
        .foregroundStyle(theme.colors.primary)
    }
}
