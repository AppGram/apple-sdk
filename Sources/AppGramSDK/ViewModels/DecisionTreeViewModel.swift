import Foundation
import Observation

/// Represents a history entry in the decision tree navigation.
public struct HistoryEntry: Sendable, Identifiable {
    /// The node ID that was visited.
    public let nodeId: String
    
    /// The question that was asked.
    public let question: String
    
    /// The answer that was given.
    public let answer: DecisionAnswer
    
    public var id: String {
        "\(nodeId)-\(answer.rawValue)"
    }
    
    public init(nodeId: String, question: String, answer: DecisionAnswer) {
        self.nodeId = nodeId
        self.question = question
        self.answer = answer
    }
}

/// Represents a Yes/No answer in the decision tree.
public enum DecisionAnswer: String, Sendable {
    case yes
    case no
}

/// View model for managing decision tree flow state and navigation.
///
/// ## Discussion
/// This view model handles decision tree navigation following the same patterns as the web app:
///
/// - Root node detection: finds node with `parent_id === null`
/// - Current node selection: shows specific node or defaults to root
/// - Answer handling: navigates to next node based on Yes/No answer
/// - History tracking: prevents loops and enables back navigation
/// - Leaf node detection: shows article when no more questions
/// - Fallback behavior: shows articles as list if no tree exists
///
/// ## Example
/// ```swift
/// let viewModel = DecisionTreeViewModel()
/// viewModel.loadFlow(helpFlow)
///
/// // Answer a question
/// viewModel.handleAnswer(.yes)
///
/// // Navigate back
/// viewModel.handleBack()
///
/// // Restart
/// viewModel.handleRestart()
/// ```
@Observable
public final class DecisionTreeViewModel: Sendable {
    // MARK: - Published Properties
    
    /// The current help flow being displayed.
    public private(set) var flow: HelpFlow?
    
    /// The current node ID being displayed.
    public private(set) var currentNodeId: String?
    
    /// The history of visited nodes and answers.
    public private(set) var nodeHistory: [HistoryEntry] = []
    
    // MARK: - Computed Properties
    
    /// All decision nodes from the flow.
    public var nodes: [HelpDecisionNode] {
        flow?.decisionNodes ?? []
    }
    
    /// The root node (node with parent_id === null).
    public var rootNode: HelpDecisionNode? {
        nodes.first { $0.parentId == nil }
    }
    
    /// The current node being displayed.
    ///
    /// If `currentNodeId` is set, returns that node.
    /// Otherwise, returns the root node.
    public var currentNode: HelpDecisionNode? {
        if let currentNodeId = currentNodeId {
            return nodes.first { $0.id == currentNodeId }
        }
        return rootNode
    }
    
    /// Set of visited node IDs (for loop prevention).
    private var visitedNodeIds: Set<String> {
        Set(nodeHistory.map { $0.nodeId })
    }
    
    /// Whether the current node is a leaf node (no Yes/No children).
    ///
    /// A leaf node has no `answerYesNodeId` and no `answerNoNodeId`.
    public var isLeafNode: Bool {
        guard let currentNode = currentNode else { return false }
        return currentNode.answerYesNodeId == nil && currentNode.answerNoNodeId == nil
    }
    
    /// The linked article for the current leaf node, if any.
    ///
    /// Returns the article only if:
    /// - The current node is a leaf node
    /// - The current node has an articleId
    /// - The article exists in the flow
    /// - The article is published
    public var linkedArticle: HelpArticle? {
        guard isLeafNode,
              let articleId = currentNode?.articleId,
              let articles = flow?.articles else {
            return nil
        }
        return articles.first { $0.id == articleId && $0.isPublished }
    }
    
    /// Whether the decision tree has nodes to display.
    public var hasNodes: Bool {
        !nodes.isEmpty && rootNode != nil
    }
    
    /// Published articles from the flow (sorted by sort_order).
    public var publishedArticles: [HelpArticle] {
        guard let articles = flow?.articles else { return [] }
        return articles
            .filter { $0.isPublished }
            .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
    }
    
    /// Whether the user can navigate back.
    public var canGoBack: Bool {
        !nodeHistory.isEmpty
    }
    
    /// Current question number (1-based).
    public var currentQuestionNumber: Int {
        nodeHistory.count + 1
    }
    
    // MARK: - Initialization
    
    public init() {}
    
    // MARK: - Public Methods
    
    /// Loads a help flow and resets to the root node.
    ///
    /// - Parameter flow: The help flow to load.
    public func loadFlow(_ flow: HelpFlow) {
        self.flow = flow
        self.currentNodeId = nil
        self.nodeHistory = []
    }
    
    /// Resets the decision tree state.
    ///
    /// Clears the current flow, history, and resets to root.
    public func reset() {
        self.flow = nil
        self.currentNodeId = nil
        self.nodeHistory = []
    }
    
    /// Handles a Yes/No answer and navigates to the next node.
    ///
    /// - Parameter answer: The answer given by the user.
    ///
    /// Logic:
    /// 1. Get the next node ID from the current node based on the answer
    /// 2. Check if the next node exists and hasn't been visited (prevents loops)
    /// 3. Add the current node and answer to history
    /// 4. Navigate to the next node
    public func handleAnswer(_ answer: DecisionAnswer) {
        guard let currentNode = currentNode else { return }
        
        // Determine next node based on answer
        let nextNodeId = answer == .yes
            ? currentNode.answerYesNodeId
            : currentNode.answerNoNodeId
        
        // Safety checks before navigating
        guard let nextNodeId = nextNodeId,
              !visitedNodeIds.contains(nextNodeId),
              getNodeById(nextNodeId) != nil else {
            return
        }
        
        // Add to history
        nodeHistory.append(HistoryEntry(
            nodeId: currentNode.id,
            question: currentNode.question,
            answer: answer
        ))
        
        // Navigate to next node
        currentNodeId = nextNodeId
    }
    
    /// Navigates back one step in the history.
    ///
    /// Removes the last history entry and returns to the previous node.
    public func handleBack() {
        guard !nodeHistory.isEmpty else { return }
        
        let previousHistory = nodeHistory.dropLast()
        let lastEntry = nodeHistory.last
        
        nodeHistory = Array(previousHistory)
        currentNodeId = lastEntry?.nodeId ?? nil
    }
    
    /// Restarts the decision tree flow.
    ///
    /// Clears history and resets to the root node.
    public func handleRestart() {
        nodeHistory = []
        currentNodeId = nil
    }
    
    // MARK: - Private Methods
    
    /// Gets a node by its ID.
    ///
    /// - Parameter id: The node ID to find.
    /// - Returns: The node if found, otherwise nil.
    private func getNodeById(_ id: String) -> HelpDecisionNode? {
        nodes.first { $0.id == id }
    }
}
