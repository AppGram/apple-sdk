import Foundation
import SwiftUI

@MainActor
@Observable
internal final class HelpViewModel {
    public private(set) var collections: [HelpCollection] = []
    public private(set) var flows: [HelpFlow] = []
    public private(set) var articles: [HelpArticle] = []
    public private(set) var isLoading = false
    public private(set) var error: AppGramError?

    public var searchQuery = "" {
        didSet {
            if searchQuery != oldValue {
                searchDebouncer.debounce { [weak self] in
                    await self?.searchArticles()
                }
            }
        }
    }

    private let helpService: HelpServiceProtocol
    private let searchDebouncer = Debouncer(delay: 0.3)

    public init(helpService: HelpServiceProtocol) {
        self.helpService = helpService
    }

    public func loadCollections() async {
        logDebug("HelpViewModel: Loading help collections and flows")
        isLoading = true
        error = nil

        do {
            // Load both collections and flows in parallel
            async let collectionsResult = helpService.getCollections()
            async let flowsResult = helpService.getFlows()

            collections = try await collectionsResult
            flows = try await flowsResult

            var allArticles: [HelpArticle] = []

            // Add articles from collections
            for collection in collections {
                if let collectionArticles = collection.articles {
                    allArticles.append(contentsOf: collectionArticles)
                }
            }

            // Add articles from flows
            for flow in flows {
                if let flowArticles = flow.articles {
                    allArticles.append(contentsOf: flowArticles)
                }
            }

            articles = allArticles
            logInfo("HelpViewModel: Loaded \(collections.count) collections, \(flows.count) flows, and \(articles.count) total articles")
        } catch let err as AppGramError {
            logError("HelpViewModel: Failed to load collections - \(err.localizedDescription)")
            error = err
        } catch {
            logError("HelpViewModel: Network error loading collections - \(error.localizedDescription)")
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public func searchArticles() async {
        guard !searchQuery.isEmpty else {
            await loadCollections()
            return
        }

        isLoading = true
        error = nil

        do {
            articles = try await helpService.getArticles(searchQuery: searchQuery)
        } catch let err as AppGramError {
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public var filteredArticles: [HelpArticle] {
        guard !searchQuery.isEmpty else { return articles }
        return articles.filter {
            $0.title.localizedCaseInsensitiveContains(searchQuery) ||
            $0.content.localizedCaseInsensitiveContains(searchQuery)
        }
    }

    public func clearError() {
        error = nil
    }

    public func refresh() async {
        await loadCollections()
    }
}

@MainActor
@Observable
internal final class HelpArticleViewModel {
    public private(set) var article: HelpArticle?
    public private(set) var isLoading = false
    public private(set) var error: AppGramError?

    private let helpService: HelpServiceProtocol

    public init(helpService: HelpServiceProtocol) {
        self.helpService = helpService
    }

    public func loadArticle(slug: String) async {
        isLoading = true
        error = nil

        do {
            article = try await helpService.getArticle(slug: slug)
        } catch let err as AppGramError {
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public func clearError() {
        error = nil
    }
}
