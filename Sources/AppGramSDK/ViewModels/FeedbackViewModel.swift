import Foundation
import SwiftUI

@MainActor
@Observable
internal final class FeedbackViewModel {
    public private(set) var wishes: [Wish] = []
    public private(set) var categories: [Category] = []
    public private(set) var isLoading = false
    public private(set) var isLoadingMore = false
    public private(set) var error: AppGramError?
    public private(set) var hasMorePages = true

    public var searchQuery = "" {
        didSet {
            if searchQuery != oldValue {
                searchDebouncer.debounce { [weak self] in
                    await self?.loadWishes()
                }
            }
        }
    }

    public var selectedCategory: Category? {
        didSet {
            if selectedCategory?.id != oldValue?.id {
                Task { await loadWishes() }
            }
        }
    }

    public var selectedStatus: WishStatus? {
        didSet {
            if selectedStatus != oldValue {
                Task { await loadWishes() }
            }
        }
    }

    public var sortBy: WishSortOption = .newest {
        didSet {
            if sortBy != oldValue {
                Task { await loadWishes() }
            }
        }
    }

    private let feedbackService: FeedbackServiceProtocol
    private var currentPage = 1
    private let pageSize = 50
    private let searchDebouncer = Debouncer(delay: 0.3)

    public init(feedbackService: FeedbackServiceProtocol) {
        self.feedbackService = feedbackService
    }

    public func loadWishes() async {
        logDebug("FeedbackViewModel: Loading wishes with status: \(String(describing: selectedStatus)), category: \(String(describing: selectedCategory?.name))")

        // Only show loading indicator on initial load
        if wishes.isEmpty {
            isLoading = true
        }
        error = nil
        currentPage = 1

        do {
            let filters = WishFilters(
                status: selectedStatus,
                categoryId: selectedCategory?.id,
                searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                sortBy: sortBy,
                page: currentPage,
                limit: pageSize
            )
            var newWishes = try await feedbackService.getWishes(filters: filters)

            // Apply locally stored vote state
            VoteStorage.shared.applyVoteState(to: &newWishes)

            // Update wishes with animation-friendly approach
            wishes = newWishes
            hasMorePages = newWishes.count >= pageSize
            logInfo("FeedbackViewModel: Loaded \(newWishes.count) wishes")
        } catch let err as AppGramError {
            logError("FeedbackViewModel: Failed to load wishes - \(err.localizedDescription)")
            error = err
        } catch {
            logError("FeedbackViewModel: Network error loading wishes - \(error.localizedDescription)")
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public func loadMoreWishes() async {
        guard !isLoadingMore, hasMorePages else { return }

        logDebug("FeedbackViewModel: Loading more wishes, page: \(currentPage + 1)")
        isLoadingMore = true
        currentPage += 1

        do {
            let filters = WishFilters(
                status: selectedStatus,
                categoryId: selectedCategory?.id,
                searchQuery: searchQuery.isEmpty ? nil : searchQuery,
                sortBy: sortBy,
                page: currentPage,
                limit: pageSize
            )
            var newWishes = try await feedbackService.getWishes(filters: filters)
            VoteStorage.shared.applyVoteState(to: &newWishes)
            wishes.append(contentsOf: newWishes)
            hasMorePages = newWishes.count >= pageSize
            logInfo("FeedbackViewModel: Loaded \(newWishes.count) more wishes")
        } catch {
            logError("FeedbackViewModel: Failed to load more wishes - \(error.localizedDescription)")
            currentPage -= 1
        }

        isLoadingMore = false
    }

    public func loadCategories() async {
        do {
            categories = try await feedbackService.getCategories()
        } catch {
            categories = []
        }
    }

    public func vote(on wish: Wish) async {
        do {
            _ = try await feedbackService.addVote(wishId: wish.id)
            if let index = wishes.firstIndex(where: { $0.id == wish.id }) {
                wishes[index].voteCount += 1
                wishes[index].hasVoted = true
            }
            VoteStorage.shared.addVote(wishId: wish.id)
        } catch let err as AppGramError {
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }
    }

    public func removeVote(from wish: Wish) async {
        do {
            try await feedbackService.removeVote(wishId: wish.id)
            if let index = wishes.firstIndex(where: { $0.id == wish.id }) {
                wishes[index].voteCount = max(0, wishes[index].voteCount - 1)
                wishes[index].hasVoted = false
            }
            VoteStorage.shared.removeVote(wishId: wish.id)
        } catch let err as AppGramError {
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }
    }

    public func submitFeedback(title: String, description: String?, categoryId: String?) async -> Bool {
        guard !title.isEmpty else {
            error = .validationError("Title is required")
            return false
        }

        isLoading = true
        error = nil

        do {
            let newWish = try await feedbackService.createWish(
                title: title,
                description: description,
                categoryId: categoryId
            )
            wishes.insert(newWish, at: 0)
            isLoading = false
            return true
        } catch let err as AppGramError {
            error = err
            isLoading = false
            return false
        } catch {
            self.error = .networkError(error.localizedDescription)
            isLoading = false
            return false
        }
    }

    public func clearError() {
        error = nil
    }

    public func refresh() async {
        await loadWishes()
    }
}
