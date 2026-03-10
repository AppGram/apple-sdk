import Foundation
import SwiftUI

/// View model for managing blog posts and content.
@MainActor
@Observable
internal final class BlogViewModel {
    public private(set) var posts: [BlogPost] = []
    public private(set) var featuredPosts: [BlogPost] = []
    public private(set) var categories: [BlogCategory] = []
    public private(set) var selectedPost: BlogPost?
    public private(set) var relatedPosts: [BlogPost] = []

    public private(set) var isLoading = false
    public private(set) var isLoadingPost = false
    public private(set) var error: AppGramError?

    public private(set) var currentPage = 1
    public private(set) var totalPages = 1
    public private(set) var totalPosts = 0

    public var filters = BlogFilters()

    private let blogService: BlogServiceProtocol

    public init(blogService: BlogServiceProtocol) {
        self.blogService = blogService
    }

    // MARK: - Load Posts

    public func loadPosts(resetPage: Bool = false) async {
        if resetPage {
            currentPage = 1
        }

        isLoading = true
        error = nil

        do {
            var currentFilters = filters
            currentFilters.page = currentPage

            let result = try await blogService.getBlogPosts(filters: currentFilters)

            posts = result.posts
            totalPages = result.totalPages
            totalPosts = result.total

            logInfo("BlogViewModel: Loaded \(posts.count) posts (page \(currentPage)/\(totalPages))")
        } catch let err as AppGramError {
            logError("BlogViewModel: Failed to load posts - \(err.localizedDescription)")
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public func loadNextPage() async {
        guard currentPage < totalPages, !isLoading else { return }

        currentPage += 1
        await loadPosts()
    }

    public func loadPreviousPage() async {
        guard currentPage > 1, !isLoading else { return }

        currentPage -= 1
        await loadPosts()
    }

    public func goToPage(_ page: Int) async {
        guard page >= 1, page <= totalPages, page != currentPage, !isLoading else { return }

        currentPage = page
        await loadPosts()
    }

    // MARK: - Load Single Post

    public func loadPost(slug: String) async {
        isLoadingPost = true
        error = nil

        do {
            selectedPost = try await blogService.getBlogPost(slug: slug)

            // Also load related posts
            relatedPosts = try await blogService.getRelatedBlogPosts(slug: slug)

            logInfo("BlogViewModel: Loaded post '\(selectedPost?.title ?? "")' with \(relatedPosts.count) related posts")
        } catch let err as AppGramError {
            logError("BlogViewModel: Failed to load post - \(err.localizedDescription)")
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoadingPost = false
    }

    // MARK: - Load Featured Posts

    public func loadFeaturedPosts() async {
        do {
            featuredPosts = try await blogService.getFeaturedBlogPosts()
            logInfo("BlogViewModel: Loaded \(featuredPosts.count) featured posts")
        } catch let err as AppGramError {
            logError("BlogViewModel: Failed to load featured posts - \(err.localizedDescription)")
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }
    }

    // MARK: - Load Categories

    public func loadCategories() async {
        do {
            categories = try await blogService.getBlogCategories()
            logInfo("BlogViewModel: Loaded \(categories.count) categories")
        } catch let err as AppGramError {
            logError("BlogViewModel: Failed to load categories - \(err.localizedDescription)")
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }
    }

    // MARK: - Search

    public func search(query: String) async {
        guard !query.isEmpty else {
            await loadPosts(resetPage: true)
            return
        }

        isLoading = true
        error = nil

        do {
            let result = try await blogService.searchBlogPosts(query: query, page: 1, perPage: filters.perPage)

            posts = result.posts
            totalPages = result.totalPages
            totalPosts = result.total
            currentPage = 1

            logInfo("BlogViewModel: Search found \(posts.count) posts matching '\(query)'")
        } catch let err as AppGramError {
            logError("BlogViewModel: Failed to search posts - \(err.localizedDescription)")
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    // MARK: - Filter by Category

    public func filterByCategory(_ categorySlug: String?) async {
        filters.categorySlug = categorySlug
        await loadPosts(resetPage: true)
    }

    // MARK: - Filter by Tag

    public func filterByTag(_ tag: String?) async {
        filters.tag = tag
        await loadPosts(resetPage: true)
    }

    // MARK: - Helpers

    public func clearError() {
        error = nil
    }

    public func clearSelectedPost() {
        selectedPost = nil
        relatedPosts = []
    }

    public var hasNextPage: Bool {
        currentPage < totalPages
    }

    public var hasPreviousPage: Bool {
        currentPage > 1
    }
}
