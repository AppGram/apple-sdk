import Foundation
import Observation

/// View model for managing wizard flow state and navigation.
///
/// ## Discussion
/// This view model handles wizard step progression, navigation controls, and progress tracking.
/// It follows the same patterns as the web app implementation:
///
/// - Steps are sorted by stepNumber in ascending order
/// - Current step is tracked using 0-based indexing
/// - Navigation includes bounds checking (can't go before step 0 or after last step)
/// - Progress is calculated as (currentStep + 1) / totalSteps
/// - State resets to step 0 when a new flow is loaded
///
/// ## Example
/// ```swift
/// let viewModel = WizardViewModel()
/// viewModel.loadFlow(helpFlow)
///
/// // Navigate forward
/// viewModel.nextStep()
///
/// // Navigate backward
/// viewModel.previousStep()
///
/// // Get current progress
/// let progress = viewModel.progress // 0.0 to 1.0
/// ```
@Observable
public final class WizardViewModel: Sendable {
    // MARK: - Published Properties

    /// The current help flow being displayed.
    public private(set) var flow: HelpFlow?

    /// The current step index (0-based).
    public private(set) var currentStep: Int = 0

    /// Sorted wizard steps.
    private var sortedSteps: [HelpWizardStep] = []

    // MARK: - Computed Properties

    /// The current step data.
    public var currentStepData: HelpWizardStep? {
        guard currentStep >= 0 && currentStep < sortedSteps.count else {
            return nil
        }
        return sortedSteps[currentStep]
    }

    /// The linked article for the current step, if any.
    ///
    /// Returns the article only if:
    /// - The current step has an articleId
    /// - The article exists in the flow
    /// - The article is published
    public var linkedArticle: HelpArticle? {
        guard let articleId = currentStepData?.articleId,
              let articles = flow?.articles else {
            return nil
        }
        return articles.first { $0.id == articleId && $0.isPublished }
    }

    /// Total number of steps.
    public var totalSteps: Int {
        sortedSteps.count
    }

    /// Progress value between 0.0 and 1.0.
    ///
    /// Formula: (currentStep + 1) / totalSteps
    /// The +1 accounts for 0-based indexing.
    public var progress: Double {
        guard totalSteps > 0 else { return 0.0 }
        return Double(currentStep + 1) / Double(totalSteps)
    }

    /// Progress percentage (0-100).
    public var progressPercentage: Int {
        Int(round(progress * 100))
    }

    /// Whether the user can go to the previous step.
    public var canGoBack: Bool {
        currentStep > 0
    }

    /// Whether the user can go to the next step.
    public var canGoForward: Bool {
        currentStep < totalSteps - 1
    }

    /// Whether the current step is the first step.
    public var isFirstStep: Bool {
        currentStep == 0
    }

    /// Whether the current step is the last step.
    public var isLastStep: Bool {
        currentStep == totalSteps - 1
    }

    /// Published articles from the flow (sorted by sort_order).
    public var publishedArticles: [HelpArticle] {
        guard let articles = flow?.articles else { return [] }
        return articles
            .filter { $0.isPublished }
            .sorted { ($0.order ?? 0) < ($1.order ?? 0) }
    }

    /// Whether the wizard has steps to display.
    public var hasSteps: Bool {
        !sortedSteps.isEmpty
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - Public Methods

    /// Loads a help flow and resets to the first step.
    ///
    /// Steps are sorted by stepNumber in ascending order.
    /// Current step is reset to 0 (first step).
    ///
    /// - Parameter flow: The help flow to load.
    public func loadFlow(_ flow: HelpFlow) {
        self.flow = flow

        // Sort wizard steps by step_number (ascending)
        self.sortedSteps = (flow.wizardSteps ?? [])
            .sorted { $0.stepNumber < $1.stepNumber }

        // Reset to first step
        self.currentStep = 0
    }

    /// Resets the wizard state.
    ///
    /// Clears the current flow and resets to step 0.
    public func reset() {
        self.flow = nil
        self.sortedSteps = []
        self.currentStep = 0
    }

    /// Navigates to the next step.
    ///
    /// Uses bounds checking to ensure we don't go past the last step.
    public func nextStep() {
        guard canGoForward else { return }
        currentStep += 1
    }

    /// Navigates to the previous step.
    ///
    /// Uses bounds checking to ensure we don't go before the first step.
    /// Formula: max(0, currentStep - 1)
    public func previousStep() {
        guard canGoBack else { return }
        currentStep = max(0, currentStep - 1)
    }

    /// Navigates to a specific step by index.
    ///
    /// - Parameter index: The step index to navigate to (0-based).
    public func goToStep(_ index: Int) {
        guard index >= 0 && index < totalSteps else { return }
        currentStep = index
    }

    /// Returns the state of a step (completed, current, or upcoming).
    ///
    /// - Parameter index: The step index to check.
    /// - Returns: The step state.
    public func stepState(at index: Int) -> StepState {
        if index < currentStep {
            return .completed
        } else if index == currentStep {
            return .current
        } else {
            return .upcoming
        }
    }
}

// MARK: - Step State

/// Represents the state of a wizard step.
public enum StepState: Sendable {
    /// The step has been completed.
    case completed

    /// The step is currently active.
    case current

    /// The step is upcoming (not yet reached).
    case upcoming
}
