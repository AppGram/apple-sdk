import Foundation
import SwiftUI

@MainActor
@Observable
internal final class SurveyViewModel {
    public private(set) var survey: Survey?
    public private(set) var currentNode: SurveyNode?
    public private(set) var nodeHistory: [SurveyNode] = []
    public private(set) var answers: [String: SurveyAnswer] = [:]
    public private(set) var isLoading = false
    public private(set) var isSubmitting = false
    public private(set) var isComplete = false
    public private(set) var resultMessage: String?
    public private(set) var error: AppGramError?

    private let surveyService: SurveyServiceProtocol
    private let projectId: String
    private let userContextProvider: @Sendable () -> UserContext?
    private let branchingEngine = BranchingEngine()

    public var progress: Double {
        guard let survey = survey, let nodes = survey.nodes, !nodes.isEmpty else {
            return 0
        }
        let answeredCount = answers.count
        return Double(answeredCount) / Double(nodes.count)
    }

    public var currentQuestionNumber: Int {
        nodeHistory.count + 1
    }

    public var totalQuestions: Int {
        survey?.nodes?.count ?? 0
    }

    public init(
        surveyService: SurveyServiceProtocol,
        projectId: String,
        userContextProvider: @escaping @Sendable () -> UserContext?
    ) {
        self.surveyService = surveyService
        self.projectId = projectId
        self.userContextProvider = userContextProvider
    }

    public func loadSurvey(slug: String) async {
        logDebug("SurveyViewModel: Loading survey with slug: \(slug)")
        isLoading = true
        error = nil

        do {
            let loadedSurvey = try await surveyService.getSurvey(slug: slug)
            survey = loadedSurvey

            if let nodes = loadedSurvey.nodes, !nodes.isEmpty {
                let sortedNodes = nodes.sorted { ($0.order ?? 0) < ($1.order ?? 0) }
                currentNode = sortedNodes.first
                logInfo("SurveyViewModel: Loaded survey '\(dump(loadedSurvey))' with \(nodes.count) questions")
            }
        } catch let err as AppGramError {
            logError("SurveyViewModel: Failed to load survey - \(err.localizedDescription)")
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public func answer(_ answer: SurveyAnswer) async {
        guard let current = currentNode else { return }

        if current.isRequired && answer.isEmpty {
            error = .validationError("This question requires an answer")
            return
        }

        logDebug("SurveyViewModel: Answering question '\(current.id)' with answer: \(String(describing: answer))")
        logDebug("SurveyViewModel: Current node - type: \(current.questionType.rawValue), answerYesNodeId: \(current.answerYesNodeId ?? "nil"), answerNoNodeId: \(current.answerNoNodeId ?? "nil"), nextNodeId: \(current.nextNodeId ?? "nil")")

        answers[current.id] = answer
        nodeHistory.append(current)

        guard let survey = survey, let nodes = survey.nodes else {
            logWarning("SurveyViewModel: Survey or nodes are nil, completing survey")
            await completeWithMessage(current.resultMessage)
            return
        }

        logDebug("SurveyViewModel: Total nodes available: \(nodes.count)")
        if let nextNode = branchingEngine.determineNextNode(for: current, answer: answer, allNodes: nodes) {
            logInfo("SurveyViewModel: Moving to next node: \(nextNode.id) - '\(nextNode.question)'")
            currentNode = nextNode
        } else {
            logInfo("SurveyViewModel: No next node found, completing survey with message: \(current.resultMessage ?? "none")")
            await completeWithMessage(current.resultMessage)
        }
    }

    public func goBack() {
        guard !nodeHistory.isEmpty else { return }

        let previousNode = nodeHistory.removeLast()
        answers.removeValue(forKey: previousNode.id)
        currentNode = previousNode
    }

    public var canGoBack: Bool {
        !nodeHistory.isEmpty
    }

    private func completeWithMessage(_ message: String?) async {
        isComplete = true
        resultMessage = message
        await submitSurvey()
    }

    private func submitSurvey() async {
        guard let survey = survey else { return }

        isSubmitting = true

        let fingerprint = await DeviceFingerprint.shared.generate()
        let userContext = userContextProvider()

        var answerPayloads: [SurveyAnswerPayload] = []
        
        for (nodeId, answer) in answers {
            guard let node = survey.nodes?.first(where: { $0.id == nodeId }) else { continue }

            let payload: SurveyAnswerPayload
            switch answer {
            case .text(let text):
                payload = SurveyAnswerPayload(
                    nodeId: nodeId,
                    answerText: text
                )
            case .options(let options):
                payload = SurveyAnswerPayload(
                    nodeId: nodeId,
                    answerOptions: options
                )
            case .rating(let rating):
                payload = SurveyAnswerPayload(
                    nodeId: nodeId,
                    answerText: String(rating)
                )
            case .boolean(let bool):
                // Use legacy answer field for yes_no questions
                payload = SurveyAnswerPayload(
                    nodeId: nodeId,
                    answer: bool ? "yes" : "no"
                )
            }
            
            answerPayloads.append(payload)
        }

        let response = SurveyResponse(
            answers: answerPayloads,
            fingerprint: fingerprint,
            externalUserId: userContext?.userId
        )

        do {
            try await surveyService.submitResponse(surveyId: survey.id, response)
        } catch let err as AppGramError {
            error = err
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isSubmitting = false
    }

    public func clearError() {
        error = nil
    }

    public func reset() {
        currentNode = survey?.nodes?.sorted { ($0.order ?? 0) < ($1.order ?? 0) }.first
        nodeHistory = []
        answers = [:]
        isComplete = false
        resultMessage = nil
        error = nil
    }
}
