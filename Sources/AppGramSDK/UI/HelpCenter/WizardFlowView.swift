import SwiftUI

/// A view that displays a wizard flow with step-by-step navigation.
///
/// ## Discussion
/// This view renders a multi-step wizard flow following the same patterns as the web app:
/// - Steps are displayed one at a time
/// - Progress indicator shows completed/current/upcoming steps
/// - Navigation buttons allow moving between steps
/// - Progress percentage is displayed
/// - Steps can optionally link to help articles
/// - Falls back to showing articles if no steps exist
///
/// ## Example
/// ```swift
/// let viewModel = WizardViewModel()
/// viewModel.loadFlow(helpFlow)
///
/// WizardFlowView(viewModel: viewModel)
/// ```
public struct WizardFlowView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @Bindable var viewModel: WizardViewModel

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(viewModel: WizardViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if viewModel.hasSteps {
                    wizardContent
                } else {
                    fallbackContent
                }
            }
        }
        .background(colors.background)
    }

    // MARK: - Wizard Content

    @ViewBuilder
    private var wizardContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            // Progress Indicator
            progressIndicator

            // Current Step Content
            if let currentStep = viewModel.currentStepData {
                stepContent(currentStep)
            } else {
                emptyStepView
            }

            // Linked Article (if any)
            if let article = viewModel.linkedArticle {
                linkedArticleSection(article)
            }

            // Navigation Buttons
            navigationButtons

            // Progress Info
            progressInfo
        }
        .padding(DesignSystem.Spacing.xl)
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs / 2)
                        .fill(colors.border.opacity(DesignSystem.Opacity.muted / 3))
                        .frame(height: 4)

                    // Progress fill
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs / 2)
                        .fill(colors.primary)
                        .frame(width: geometry.size.width * viewModel.progress, height: 4)
                        .animation(DesignSystem.Animation.easeInOut, value: viewModel.progress)
                }
            }
            .frame(height: 4)

            // Step Indicators
            HStack(spacing: DesignSystem.Spacing.md) {
                ForEach(0..<viewModel.totalSteps, id: \.self) { index in
                    stepIndicator(index: index)
                }
            }
        }
    }

    private func stepIndicator(index: Int) -> some View {
        let state = viewModel.stepState(at: index)

        return Button {
            viewModel.goToStep(index)
        } label: {
            VStack(spacing: DesignSystem.Spacing.xs) {
                // Circle indicator
                ZStack {
                    Circle()
                        .fill(indicatorColor(for: state))
                        .frame(width: 32, height: 32)

                    if state == .completed {
                        Image(systemName: "checkmark")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.bold))
                            .foregroundColor(.white)
                    } else {
                        Text("\(index + 1)")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(indicatorTextColor(for: state))
                    }
                }

                // Step number label
                Text("Step \(index + 1)")
                    .font(.system(size: 11))
                    .foregroundColor(state == .current ? colors.text : colors.text.opacity(DesignSystem.Opacity.disabled))
            }
        }
        .buttonStyle(.plain)
    }

    private func indicatorColor(for state: StepState) -> Color {
        switch state {
        case .completed:
            return colors.primary
        case .current:
            return colors.primary
        case .upcoming:
            return colors.border.opacity(DesignSystem.Opacity.disabled)
        }
    }

    private func indicatorTextColor(for state: StepState) -> Color {
        switch state {
        case .completed:
            return .white
        case .current:
            return .white
        case .upcoming:
            return colors.text.opacity(DesignSystem.Opacity.disabled)
        }
    }

    // MARK: - Step Content

    private func stepContent(_ step: HelpWizardStep) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            // Step Title
            Text(step.title)
                .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                .foregroundColor(colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Step Content (HTML)
            HTMLContentView(
                htmlContent: step.content,
                textColor: colors.text,
                backgroundColor: colors.background
            )
            .id(step.id) // Use step ID as key for animations
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .layeredShadow()
    }

    private var emptyStepView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.disabled))

            Text("Step not found")
                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }

    // MARK: - Linked Article Section

    private func linkedArticleSection(_ article: HelpArticle) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            HStack {
                Image(systemName: "book.fill")
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.primary)

                Text("Related Article")
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

                Spacer()
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text(article.title)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                if let excerpt = article.excerpt {
                    Text(excerpt)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                        .lineLimit(2)
                }

                // Article Content
                HTMLContentView(
                    htmlContent: article.content,
                    textColor: colors.text,
                    backgroundColor: colors.cardBackground
                )
            }
            .padding(DesignSystem.Spacing.lg)
            .background(colors.cardBackground.opacity(DesignSystem.Opacity.disabled))
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
        }
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Previous Button
            Button {
                viewModel.previousStep()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))

                    Text("Previous")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(viewModel.canGoBack ? colors.cardBackground : colors.border.opacity(DesignSystem.Opacity.disabled))
                .foregroundColor(viewModel.canGoBack ? colors.text : colors.text.opacity(DesignSystem.Opacity.disabled))
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                )
            }
            .disabled(!viewModel.canGoBack)

            // Next / Complete Button
            Button {
                if viewModel.canGoForward {
                    viewModel.nextStep()
                }
            } label: {
                HStack {
                    Text(viewModel.isLastStep ? "Complete Guide" : "Next Step")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))

                    if !viewModel.isLastStep {
                        Image(systemName: "chevron.right")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(colors.primary)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
            }
            .disabled(viewModel.isLastStep)
        }
    }

    // MARK: - Progress Info

    private var progressInfo: some View {
        HStack {
            Spacer()
            Text("\(viewModel.progressPercentage)% Complete")
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            Spacer()
        }
        .padding(.top, DesignSystem.Spacing.sm)
    }

    // MARK: - Fallback Content

    @ViewBuilder
    private var fallbackContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            if viewModel.publishedArticles.isEmpty {
                // Empty state - no steps and no articles
                EmptyStateView(
                    icon: "doc.text.magnifyingglass",
                    title: "No Content Available",
                    message: "This guide doesn't have any steps or articles yet."
                )
                .padding(DesignSystem.Spacing.xxxl)
            } else {
                // Show articles as fallback
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    Text("Articles")
                        .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                        .foregroundColor(colors.text)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.top, DesignSystem.Spacing.xl)

                    ForEach(viewModel.publishedArticles) { article in
                        articleCard(article)
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                    }
                }
            }
        }
    }

    private func articleCard(_ article: HelpArticle) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text(article.title)
                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            if let excerpt = article.excerpt {
                Text(excerpt)
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                    .lineLimit(3)
            }

            HTMLContentView(
                htmlContent: article.content,
                textColor: colors.text,
                backgroundColor: colors.cardBackground
            )
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .layeredShadow()
    }
}
