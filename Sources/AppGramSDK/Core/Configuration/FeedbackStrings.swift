import Foundation

/// Customizable strings for the feedback UI.
///
/// Allows SDK users to override all text labels in the feedback module.
///
/// ## Example
/// ```swift
/// let strings = FeedbackStrings(
///     feedbackTitle: "Feature Requests",
///     submitTitle: "Submit Request",
///     titleLabel: "Title",
///     descriptionLabel: "Description"
/// )
/// ```
public struct FeedbackStrings: Sendable {
    // MARK: - Navigation Titles

    /// Title for the feedback list view
    public let feedbackTitle: String

    /// Title for the submit feedback view
    public let submitTitle: String

    /// Title for the feedback detail view
    public let detailTitle: String

    // MARK: - Filter Labels

    /// Label for status filter when no status is selected
    public let statusFilterLabel: String

    /// Label for showing all statuses
    public let allStatusesLabel: String

    /// Label for category filter when no category is selected
    public let categoryFilterLabel: String

    /// Label for showing all categories
    public let allCategoriesLabel: String

    /// Prefix for sort filter
    public let sortPrefix: String

    // MARK: - Form Labels

    /// Label for title input field
    public let titleLabel: String

    /// Placeholder hint for title input
    public let titleHint: String

    /// Placeholder for title input field
    public let titlePlaceholder: String

    /// Label for description input field
    public let descriptionLabel: String

    /// Placeholder hint for description input
    public let descriptionHint: String

    // MARK: - Buttons

    /// Text for submit button
    public let submitButtonLabel: String

    /// Text for cancel button
    public let cancelButtonLabel: String

    /// Text for close button
    public let closeButtonLabel: String

    // MARK: - Comments

    /// Label for comments section
    public let commentsLabel: String

    /// Label for add comment section
    public let addCommentLabel: String

    /// Button text for posting a comment
    public let postCommentLabel: String

    /// Message when no comments exist
    public let noCommentsMessage: String

    // MARK: - Empty State

    /// Title for empty feedback list
    public let emptyTitle: String

    /// Message for empty feedback list
    public let emptyMessage: String

    /// Button text for empty state action
    public let emptyActionLabel: String

    // MARK: - Success Messages

    /// Message shown when feedback is submitted successfully
    public let submittedMessage: String

    // MARK: - Search

    /// Placeholder for search field
    public let searchPlaceholder: String

    // MARK: - Misc

    /// Prefix for author attribution
    public let byAuthorPrefix: String

    public init(
        feedbackTitle: String = "Feedback",
        submitTitle: String = "Submit Feedback",
        detailTitle: String = "Feedback",
        statusFilterLabel: String = "Status",
        allStatusesLabel: String = "All Statuses",
        categoryFilterLabel: String = "Category",
        allCategoriesLabel: String = "All Categories",
        sortPrefix: String = "Sort",
        titleLabel: String = "Title",
        titleHint: String = "Give your feedback a clear, concise title",
        titlePlaceholder: String = "e.g., Add dark mode support",
        descriptionLabel: String = "Description",
        descriptionHint: String = "Provide more details about your suggestion (optional)",
        submitButtonLabel: String = "Submit Feedback",
        cancelButtonLabel: String = "Cancel",
        closeButtonLabel: String = "Close",
        commentsLabel: String = "Comments",
        addCommentLabel: String = "Add a Comment",
        postCommentLabel: String = "Post Comment",
        noCommentsMessage: String = "No comments yet. Be the first to comment!",
        emptyTitle: String = "No Feedback Yet",
        emptyMessage: String = "Be the first to share your ideas!",
        emptyActionLabel: String = "Submit Feedback",
        submittedMessage: String = "Feedback Submitted!",
        searchPlaceholder: String = "Search feedback...",
        byAuthorPrefix: String = "by"
    ) {
        self.feedbackTitle = feedbackTitle
        self.submitTitle = submitTitle
        self.detailTitle = detailTitle
        self.statusFilterLabel = statusFilterLabel
        self.allStatusesLabel = allStatusesLabel
        self.categoryFilterLabel = categoryFilterLabel
        self.allCategoriesLabel = allCategoriesLabel
        self.sortPrefix = sortPrefix
        self.titleLabel = titleLabel
        self.titleHint = titleHint
        self.titlePlaceholder = titlePlaceholder
        self.descriptionLabel = descriptionLabel
        self.descriptionHint = descriptionHint
        self.submitButtonLabel = submitButtonLabel
        self.cancelButtonLabel = cancelButtonLabel
        self.closeButtonLabel = closeButtonLabel
        self.commentsLabel = commentsLabel
        self.addCommentLabel = addCommentLabel
        self.postCommentLabel = postCommentLabel
        self.noCommentsMessage = noCommentsMessage
        self.emptyTitle = emptyTitle
        self.emptyMessage = emptyMessage
        self.emptyActionLabel = emptyActionLabel
        self.submittedMessage = submittedMessage
        self.searchPlaceholder = searchPlaceholder
        self.byAuthorPrefix = byAuthorPrefix
    }

    /// Default strings configuration
    public static let `default` = FeedbackStrings()
}
