import Foundation
import SwiftUI

/// Configuration options for customizing the help center view appearance and behavior.
///
/// ## Discussion
/// Use this configuration to customize how the help center displays content, including
/// button colors for decision tree nodes and article display behavior.
///
/// ## Example
/// ```swift
/// // Single color for both buttons
/// let config = HelpCenterConfiguration(
///     decisionTreeButtonColor: .blue,
///     articleDisplayBehavior: .pushToStack
/// )
///
/// // Different colors for Yes and No buttons
/// let config = HelpCenterConfiguration(
///     yesButtonColor: .green,
///     noButtonColor: .red,
///     articleDisplayBehavior: .inline
/// )
/// ```
public struct HelpCenterConfiguration: Sendable {
    /// The color for Yes buttons in decision tree flows.
    ///
    /// If `nil`, falls back to `decisionTreeButtonColor`, then to the theme's primary color.
    public var yesButtonColor: Color?
    
    /// The color for No buttons in decision tree flows.
    ///
    /// If `nil`, falls back to `decisionTreeButtonColor`, then to the theme's primary color.
    public var noButtonColor: Color?
    
    /// Private stored property for legacy button color (to avoid getter issues)
    private var _legacyButtonColor: Color?
    
    /// The color for Yes/No buttons in decision tree flows (legacy support).
    ///
    /// If `yesButtonColor` or `noButtonColor` are set, this is ignored.
    /// If `nil`, uses the theme's primary color.
    @available(*, deprecated, message: "Use yesButtonColor and noButtonColor for separate button colors")
    public var decisionTreeButtonColor: Color? {
        get {
            // Return stored legacy color if both yes and no are nil
            if yesButtonColor == nil && noButtonColor == nil {
                return _legacyButtonColor
            }
            // Return yesButtonColor if both are the same (for backward compatibility)
            if let yes = yesButtonColor, let no = noButtonColor {
                // Can't compare Color directly, so return yes if both are set
                // (This is a limitation, but for most cases it works)
                return yes
            }
            return _legacyButtonColor
        }
        set {
            // Store the legacy color separately
            _legacyButtonColor = newValue
            // Set both to the same value for backward compatibility only if they're not already set
            if yesButtonColor == nil && noButtonColor == nil {
                yesButtonColor = newValue
                noButtonColor = newValue
            }
        }
    }
    
    /// The behavior when an article is found in a decision tree.
    ///
    /// - `.inline`: Display the article content directly in the decision tree view
    /// - `.pushToStack`: Push the article detail view onto the navigation stack
    /// - `.sheet`: Present the article in a sheet modal
    /// - `.replace`: Replace the current decision tree view with the article view
    public var articleDisplayBehavior: ArticleDisplayBehavior
    
    public init(
        yesButtonColor: Color? = nil,
        noButtonColor: Color? = nil,
        decisionTreeButtonColor: Color? = nil,
        articleDisplayBehavior: ArticleDisplayBehavior = .inline
    ) {
        // Store legacy color separately
        self._legacyButtonColor = decisionTreeButtonColor
        
        // If legacy decisionTreeButtonColor is provided and neither yes/no is set, use it for both
        if let legacyColor = decisionTreeButtonColor, yesButtonColor == nil && noButtonColor == nil {
            self.yesButtonColor = legacyColor
            self.noButtonColor = legacyColor
        } else {
            self.yesButtonColor = yesButtonColor
            self.noButtonColor = noButtonColor
        }
        self.articleDisplayBehavior = articleDisplayBehavior
    }
    
    public static let `default` = HelpCenterConfiguration()
}

/// Defines how articles are displayed when found in a decision tree.
public enum ArticleDisplayBehavior: Sendable {
    /// Display the article content directly inline in the decision tree view.
    ///
    /// The article content replaces the question view but remains in the same navigation context.
    case inline
    
    /// Push the article detail view onto the navigation stack.
    ///
    /// The article opens in a new screen that can be navigated back from.
    case pushToStack
    
    /// Present the article in a sheet modal.
    ///
    /// The article appears in a modal sheet that can be dismissed.
    case sheet
    
    /// Replace the current decision tree view with the article view.
    ///
    /// The decision tree view is replaced entirely, removing it from the navigation stack.
    case replace
}
