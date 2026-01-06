import Foundation
import SwiftUI

@MainActor
@Observable
internal final class FeedbackDetailViewModel {
    public private(set) var wish: Wish
    public private(set) var comments: [Comment] = []
    public private(set) var isLoading = false
    public private(set) var isSubmittingComment = false
    public private(set) var error: AppGramError?

    public var newCommentText = ""

    private let feedbackService: FeedbackServiceProtocol

    public init(wish: Wish, feedbackService: FeedbackServiceProtocol) {
        var mutableWish = wish
        VoteStorage.shared.applyVoteState(to: &mutableWish)
        self.wish = mutableWish
        self.feedbackService = feedbackService
    }

    public func loadComments() async {
        logDebug("FeedbackDetailViewModel: Loading comments for wish: \(wish.id)")
        isLoading = true
        error = nil

        do {
            comments = try await feedbackService.getComments(wishId: wish.id)
            logInfo("FeedbackDetailViewModel: Loaded \(comments.count) comments")
        } catch let err as AppGramError {
            logError("FeedbackDetailViewModel: Failed to load comments - \(err.localizedDescription)")
            error = err
        } catch {
            logError("FeedbackDetailViewModel: Network error loading comments - \(error.localizedDescription)")
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public func addComment() async -> Bool {
        let content = newCommentText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else {
            error = .validationError("Comment cannot be empty")
            return false
        }

        isSubmittingComment = true
        error = nil

        do {
            let comment = try await feedbackService.addComment(wishId: wish.id, content: content)
            comments.append(comment)
            newCommentText = ""
            isSubmittingComment = false
            return true
        } catch let err as AppGramError {
            error = err
            isSubmittingComment = false
            return false
        } catch {
            self.error = .networkError(error.localizedDescription)
            isSubmittingComment = false
            return false
        }
    }

    public func vote() async {
        logDebug("FeedbackDetailViewModel: Adding vote for wish: \(wish.id)")
        do {
            _ = try await feedbackService.addVote(wishId: wish.id)
            wish.voteCount += 1
            wish.hasVoted = true
            VoteStorage.shared.addVote(wishId: wish.id)
            logInfo("FeedbackDetailViewModel: Successfully added vote, new count: \(wish.voteCount)")
        } catch let err as AppGramError {
            logError("FeedbackDetailViewModel: Failed to vote - \(err.localizedDescription)")
            error = err
        } catch {
            logError("FeedbackDetailViewModel: Network error voting - \(error.localizedDescription)")
            self.error = .networkError(error.localizedDescription)
        }
    }

    public func removeVote() async {
        do {
            try await feedbackService.removeVote(wishId: wish.id)
            wish.voteCount = max(0, wish.voteCount - 1)
            wish.hasVoted = false
            VoteStorage.shared.removeVote(wishId: wish.id)
        } catch let err as AppGramError {
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }
    }

    public func clearError() {
        error = nil
    }

    public func refresh() async {
        await loadComments()
    }
}
