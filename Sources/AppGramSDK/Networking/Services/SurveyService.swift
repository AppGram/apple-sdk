import Foundation

/// Protocol for interacting with survey functionality.
///
/// ## Discussion
/// The survey service provides methods to load surveys and submit survey responses.
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getSurveyService()
/// let survey = try await service.getSurvey(slug: "nps")
/// ```
public protocol SurveyServiceProtocol: Sendable {
    func getSurvey(slug: String) async throws -> Survey
    func submitResponse(surveyId: String, _ response: SurveyResponse) async throws
}

internal actor SurveyService: SurveyServiceProtocol {
    private let apiClient: APIClient
    private let projectId: String
    private let userContextProvider: @Sendable () -> UserContext?

    public init(
        apiClient: APIClient,
        projectId: String,
        userContextProvider: @escaping @Sendable () -> UserContext?
    ) {
        self.apiClient = apiClient
        self.projectId = projectId
        self.userContextProvider = userContextProvider
    }

    public func getSurvey(slug: String) async throws -> Survey {
        logDebug("Getting survey with slug: \(slug)")
        let response: APIResponse<Survey> = try await apiClient.get(endpoint: .survey(slug: slug))
        logInfo("Fetched survey: \(dump(response.data))")
        return response.data
    }

    public func submitResponse(surveyId: String, _ response: SurveyResponse) async throws {
        logInfo("Submitting survey response for survey: \(surveyId)")
        try await apiClient.post(endpoint: .submitSurveyResponse(surveyId: surveyId), body: response)
        logInfo("Successfully submitted survey response")
    }
}

internal struct BranchingEngine: Sendable {
    public init() {}

    public func determineNextNode(
        for node: SurveyNode,
        answer: SurveyAnswer,
        allNodes: [SurveyNode]
    ) -> SurveyNode? {
        // Sort nodes by order for fallback navigation
        let sortedNodes = allNodes.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
        
        // Priority 1: Yes/No specific branches (legacy support)
        // Only for yes_no question type, and only use answer_yes_node_id or answer_no_node_id
        if node.questionType == .yesNo, case .boolean(let value) = answer {
            let nextNodeId = value ? node.answerYesNodeId : node.answerNoNodeId
            if let nodeId = nextNodeId {
                if let foundNode = allNodes.first(where: { $0.id == nodeId }) {
                    logDebug("BranchingEngine: Priority 1 - Found next node via yes/no branch: \(nodeId)")
                    return foundNode
                } else {
                    logWarning("BranchingEngine: Priority 1 - Yes/no node ID '\(nodeId)' not found in allNodes")
                }
            }
            // If yes/no IDs are nil, continue to Priority 2 (branches)
        }
        
        // Priority 2: Conditional branches (new system)
        if let branches = node.branches, !branches.isEmpty {
            for branch in branches {
                if evaluateCondition(branch.condition, answer: answer) {
                    if let foundNode = allNodes.first(where: { $0.id == branch.nextNodeId }) {
                        logDebug("BranchingEngine: Priority 2 - Found next node via conditional branch: \(branch.nextNodeId)")
                        return foundNode
                    } else {
                        logWarning("BranchingEngine: Priority 2 - Branch node ID '\(branch.nextNodeId)' not found in allNodes")
                    }
                }
            }
        }
        
        // Priority 3: Direct next_node_id
        if let nextNodeId = node.nextNodeId {
            if let foundNode = allNodes.first(where: { $0.id == nextNodeId }) {
                logDebug("BranchingEngine: Priority 3 - Found next node via next_node_id: \(nextNodeId)")
                return foundNode
            } else {
                logWarning("BranchingEngine: Priority 3 - Next node ID '\(nextNodeId)' not found in allNodes")
            }
        }
        
        // Priority 4: Check if endpoint (has result_message)
        if node.resultMessage != nil {
            logDebug("BranchingEngine: Priority 4 - Node is an endpoint (has result_message). Survey complete.")
            return nil
        }
        
        // Priority 5: Fallback to next node in sort_order
        // Find current node's index in sorted array, then get next one
        if let currentIndex = sortedNodes.firstIndex(where: { $0.id == node.id }),
           currentIndex + 1 < sortedNodes.count {
            let nextNode = sortedNodes[currentIndex + 1]
            logDebug("BranchingEngine: Priority 5 - Found next node by sort_order: \(nextNode.id) (order: \(nextNode.order ?? 0))")
            return nextNode
        }
        
        // No next node found - survey is complete
        logDebug("BranchingEngine: No next node found. Survey complete.")
        return nil
    }

    private func evaluateCondition(_ condition: BranchCondition, answer: SurveyAnswer) -> Bool {
        switch condition.type {
        case .equals:
            return evaluateEquals(condition.value, answer: answer)
        case .contains:
            return evaluateContains(condition.value, answer: answer)
        case .greaterThan:
            return evaluateComparison(condition.value, answer: answer) { $0 > $1 }
        case .lessThan:
            return evaluateComparison(condition.value, answer: answer) { $0 < $1 }
        case .greaterThanOrEqual:
            return evaluateComparison(condition.value, answer: answer) { $0 >= $1 }
        case .lessThanOrEqual:
            return evaluateComparison(condition.value, answer: answer) { $0 <= $1 }
        }
    }

    private func evaluateEquals(_ conditionValue: AnyCodableValue, answer: SurveyAnswer) -> Bool {
        switch (conditionValue, answer) {
        case (.string(let expected), .text(let actual)):
            return expected.lowercased() == actual.lowercased()
        case (.string(let expected), .options(let actual)):
            return actual.contains { $0.lowercased() == expected.lowercased() }
        case (.int(let expected), .rating(let actual)):
            return expected == actual
        case (.bool(let expected), .boolean(let actual)):
            return expected == actual
        default:
            return false
        }
    }

    private func evaluateContains(_ conditionValue: AnyCodableValue, answer: SurveyAnswer) -> Bool {
        guard case .string(let expected) = conditionValue else { return false }

        switch answer {
        case .text(let actual):
            return actual.lowercased().contains(expected.lowercased())
        case .options(let actual):
            return actual.contains { $0.lowercased().contains(expected.lowercased()) }
        default:
            return false
        }
    }

    private func evaluateComparison(
        _ conditionValue: AnyCodableValue,
        answer: SurveyAnswer,
        comparator: (Int, Int) -> Bool
    ) -> Bool {
        guard case .rating(let actualValue) = answer else { return false }

        switch conditionValue {
        case .int(let expected):
            return comparator(actualValue, expected)
        case .double(let expected):
            return comparator(actualValue, Int(expected))
        default:
            return false
        }
    }
}
