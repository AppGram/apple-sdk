import SwiftUI

/// A view that displays a decision tree flow with Yes/No navigation.
///
/// ## Discussion
/// This view renders a decision tree flow following the same patterns as the web app:
/// - Questions are displayed one at a time
/// - Yes/No buttons navigate to different nodes
/// - Progress tracking shows current question number
/// - History tracking prevents loops and enables back navigation
/// - Leaf nodes automatically show linked articles
/// - Falls back to showing articles if no tree exists
///
/// ## Example
/// ```swift
/// let viewModel = DecisionTreeViewModel()
/// viewModel.loadFlow(helpFlow)
///
/// DecisionTreeFlowView(viewModel: viewModel)
/// ```
public struct DecisionTreeFlowView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @Bindable var viewModel: DecisionTreeViewModel
    
    private let configuration: HelpCenterConfiguration
    private let onArticleSelected: ((HelpArticle) -> Void)?

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }
    
    private var yesButtonColor: Color {
        // Priority: yesButtonColor > legacy decisionTreeButtonColor > theme primary
        if let yesColor = configuration.yesButtonColor {
            return yesColor
        }
        // Only use legacy color if both yes and no are nil (backward compatibility)
        if configuration.noButtonColor == nil, let legacyColor = configuration.decisionTreeButtonColor {
            return legacyColor
        }
        return colors.primary
    }
    
    private var noButtonColor: Color {
        // Priority: noButtonColor > legacy decisionTreeButtonColor > theme primary
        if let noColor = configuration.noButtonColor {
            return noColor
        }
        // Only use legacy color if both yes and no are nil (backward compatibility)
        if configuration.yesButtonColor == nil, let legacyColor = configuration.decisionTreeButtonColor {
            return legacyColor
        }
        return colors.error
    }

    public init(
        viewModel: DecisionTreeViewModel,
        configuration: HelpCenterConfiguration = .default,
        onArticleSelected: ((HelpArticle) -> Void)? = nil
    ) {
        self.viewModel = viewModel
        self.configuration = configuration
        self.onArticleSelected = onArticleSelected
    }

    public var body: some View {
        ZStack {
            backgroundView

            ScrollView {
                VStack(spacing: 0) {
                    if viewModel.hasNodes {
                        decisionTreeContent
                    } else {
                        fallbackContent
                    }
                }
            }
        }
    }

    // MARK: - Decision Tree Content

    @ViewBuilder
    private var decisionTreeContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            headerCard(
                title: configuration.decisionTreeTitle ?? "Decision Tree",
                subtitle: configuration.decisionTreeSubtitle ?? "Answer a few quick questions to find the right solution."
            )

            // Progress Indicator
            progressIndicator

            // Current Question or Solution
            if let linkedArticle = viewModel.linkedArticle {
                // Show solution at leaf node (only if inline behavior)
                if configuration.articleDisplayBehavior == .inline {
                    solutionView(linkedArticle)
                } else {
                    // For non-inline behaviors, show a button to open the article
                    articleButtonView(linkedArticle)
                }
            } else if let currentNode = viewModel.currentNode {
                // Show question with Yes/No options
                questionView(currentNode)
            } else {
                emptyNodeView
            }

            // Navigation Buttons
            navigationButtons
        }
        .padding(DesignSystem.Spacing.xl)
    }

    // MARK: - Progress Indicator

    private var progressIndicator: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            HStack {
                if viewModel.linkedArticle != nil {
                    Text("Solution found after \(viewModel.nodeHistory.count) question\(viewModel.nodeHistory.count == 1 ? "" : "s")")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                        .foregroundColor(colors.neutral500)
                } else {
                    Text("Question \(viewModel.currentQuestionNumber)")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                        .foregroundColor(colors.neutral500)
                }
                Spacer()

                if !viewModel.nodes.isEmpty {
                    Text("\(viewModel.currentQuestionNumber)/\(viewModel.nodes.count)")
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.primary)
                        .padding(.horizontal, DesignSystem.Spacing.sm)
                        .padding(.vertical, DesignSystem.Spacing.xs)
                        .background(colors.primary.opacity(0.12), in: Capsule())
                }
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }

    // MARK: - Question View

    private func questionView(_ node: HelpDecisionNode) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            Text(configuration.decisionTreePrompt ?? "Choose an answer")
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                .foregroundColor(colors.neutral500)

            // Question Text
            Text(node.question)
                .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                .foregroundColor(colors.text)
                .frame(maxWidth: .infinity, alignment: .leading)
                .id(node.id) // Use node ID as key for animations

            // Yes/No Buttons
            VStack(spacing: DesignSystem.Spacing.md) {
                // Yes Button (only shown if answer_yes_node_id exists)
                if let _ = node.answerYesNodeId {
                    answerButton(
                        text: configuration.decisionTreeYesLabel ?? "Yes",
                        answer: .yes,
                        icon: "checkmark.circle.fill",
                        color: yesButtonColor
                    )
                }

                // No Button (only shown if answer_no_node_id exists)
                if let _ = node.answerNoNodeId {
                    answerButton(
                        text: configuration.decisionTreeNoLabel ?? "No",
                        answer: .no,
                        icon: "xmark.circle.fill",
                        color: noButtonColor
                    )
                }
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .layeredShadow()
    }

    private func answerButton(text: String, answer: DecisionAnswer, icon: String, color: Color) -> some View {
        Button {
            viewModel.handleAnswer(answer)
        } label: {
            HStack {
                ZStack {
                    Circle()
                        .fill(colors.cardBackground.opacity(0.25))
                        .frame(width: 32, height: 32)
                    Image(systemName: icon)
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                }

                Text(text)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
            }
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .foregroundColor(.white)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        }
        .buttonStyle(.plain)
    }

    private var emptyNodeView: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.disabled))

            Text("Question not found")
                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
        }
        .frame(maxWidth: .infinity)
        .padding(DesignSystem.Spacing.xxxl)
    }

    // MARK: - Article Button View (for non-inline behaviors)
    
    private func articleButtonView(_ article: HelpArticle) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            // Solution Header
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: DesignSystem.Typography.xxl))
                    .foregroundColor(yesButtonColor)

                Text(configuration.decisionTreeSolutionTitle ?? "We found a solution!")
                    .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                    .foregroundColor(colors.text)

                Spacer()
            }

            // Article Preview
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text(article.title)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                if let excerpt = article.excerpt {
                    Text(excerpt)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.neutral500)
                        .lineLimit(3)
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
            )

            // Open Article Button
            Button {
                onArticleSelected?(article)
            } label: {
                HStack {
                    Text(configuration.decisionTreeViewArticleLabel ?? "View Article")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .foregroundColor(.white)
                .background(yesButtonColor)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            }
            .buttonStyle(.plain)
        }
        .padding(DesignSystem.Spacing.xl)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .layeredShadow()
    }

    // MARK: - Solution View

    private func solutionView(_ article: HelpArticle) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
            // Solution Header
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: DesignSystem.Typography.xxl))
                    .foregroundColor(colors.primary)

                Text("We found a solution!")
                    .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                    .foregroundColor(colors.text)

                Spacer()
            }

            // Article Content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Text(article.title)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                if let excerpt = article.excerpt {
                    Text(excerpt)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.neutral500)
                        .lineLimit(3)
                }

                // Article Content
                HTMLContentView(
                    htmlContent: article.content,
                    textColor: colors.text,
                    backgroundColor: colors.cardBackground
                )
            }
            .padding(DesignSystem.Spacing.lg)
            .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                    .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
            )
        }
        .padding(DesignSystem.Spacing.xl)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .layeredShadow()
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            // Back Button
            Button {
                viewModel.handleBack()
            } label: {
                HStack {
                    Image(systemName: "chevron.left")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))

                    Text(configuration.decisionTreeBackLabel ?? "Back")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(viewModel.canGoBack ? colors.cardBackground : colors.cardBackground.opacity(0.6))
                .foregroundColor(viewModel.canGoBack ? colors.text : colors.neutral500)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                )
            }
            .disabled(!viewModel.canGoBack)

            // Restart Button
            Button {
                viewModel.handleRestart()
            } label: {
                HStack {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))

                    Text(configuration.decisionTreeRestartLabel ?? "Restart")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                }
                .frame(maxWidth: .infinity)
                .frame(height: 48)
                .background(colors.cardBackground)
                .foregroundColor(colors.text)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                        .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                )
            }
        }
    }

    // MARK: - Fallback Content

    @ViewBuilder
    private var fallbackContent: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            if viewModel.publishedArticles.isEmpty {
                // Empty state - no nodes and no articles
                EmptyStateView(
                    icon: "doc.text.magnifyingglass",
                    title: "No Content Available",
                    message: "This decision tree doesn't have any questions or articles yet."
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
                        .foregroundColor(colors.neutral500)
                        .lineLimit(3)
                }

            HTMLContentView(
                htmlContent: article.content,
                textColor: colors.text,
                backgroundColor: colors.cardBackground
            )
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [colors.background, colors.neutral100],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Circle()
                .fill(colors.neutral200.opacity(0.35))
                .frame(width: 240, height: 240)
                .offset(x: 140, y: -140)
        )
        .ignoresSafeArea()
    }

    private func headerCard(title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            Text(title)
                .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.semibold, design: .serif))
                .foregroundColor(colors.text)

            Text(subtitle)
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.neutral500)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
    }
}
