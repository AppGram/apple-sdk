import SwiftUI

public enum SurveyStyle {
    case normal
    case typeform
}

public struct SurveyView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: SurveyViewModel
    @State private var questionTransition: Bool = false
    @State private var scrollToTop: Bool = false
    @State private var showWelcome: Bool = true
    @State private var showCompletionAnimation: Bool = false

    @State private var textAnswer = ""
    @State private var selectedOption: String?
    @State private var selectedOptions: Set<String> = []
    @State private var rating: Int?

    private let slug: String
    private let style: SurveyStyle

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        slug: String,
        surveyService: SurveyServiceProtocol,
        projectId: String,
        userContextProvider: @escaping @Sendable () -> UserContext?,
        style: SurveyStyle = .normal
    ) {
        self.slug = slug
        self.style = style
        _viewModel = State(initialValue: SurveyViewModel(
            surveyService: surveyService,
            projectId: projectId,
            userContextProvider: userContextProvider
        ))
    }

    public var body: some View {
        Group {
            switch style {
            case .normal:
                normalStyleView
            case .typeform:
                typeformStyleView
            }
        }
        .task {
            await viewModel.loadSurvey(slug: slug)
        }
        .onChange(of: viewModel.currentNode?.id) { _ in
            // Only animate transitions between questions, not on initial load
            guard !showWelcome else { return }

            // Trigger transition animation when question changes
            withAnimation(.easeInOut(duration: 0.3)) {
                questionTransition = true
            }

            // Trigger scroll to top when question changes (for Typeform style)
            if style == .typeform {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    scrollToTop.toggle()
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                questionTransition = false
            }
        }
        .onChange(of: viewModel.isComplete) { isComplete in
            if isComplete {
                // Trigger completion animation with a slight delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    showCompletionAnimation = true
                }
            }
        }
    }
    
    // MARK: - Normal Style View
    private var normalStyleView: some View {
        NavigationStack {
            ZStack {
                backgroundView
                content
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                        }
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    }
                }
        }
    }
    
    // MARK: - Typeform Style View
    private var typeformStyleView: some View {
        ZStack {
            backgroundView

            VStack(spacing: 0) {
                // Minimal top bar with progress
                topBar

                // Main content area
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .id(showWelcome ? "welcome" : (viewModel.isComplete ? "complete" : "question"))
            }
        }
    }
    
    private var topBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: DesignSystem.Spacing.lg) {
                Button {
                    dismiss()
                } label: {
                    ZStack {
                        Circle()
                            .fill(colors.cardBackground)
                            .frame(width: DesignSystem.Spacing.xxl + 8, height: DesignSystem.Spacing.xxl + 8)

                        Image(systemName: "xmark")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                    }
                }

                Spacer()

                if !showWelcome, let survey = viewModel.survey {
                    VStack(spacing: DesignSystem.Spacing.xs - 2) {
                        Text(survey.name)
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text)
                            .lineLimit(1)

                        Text("\(viewModel.currentQuestionNumber)/\(viewModel.totalQuestions)")
                            .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.medium))
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                    }
                    .transition(.opacity)
                } else {
                    // Spacer to maintain layout
                    Color.clear.frame(height: 1)
                }

                Spacer()

                // Progress percentage
                if !showWelcome {
                    Text("\(Int(viewModel.progress * 100))%")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.primary)
                        .frame(width: DesignSystem.Spacing.xxl + 8)
                        .transition(.opacity)
                } else {
                    // Spacer to maintain layout
                    Color.clear.frame(width: DesignSystem.Spacing.xxl + 8)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.top, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.md)

            // Enhanced progress bar
            if !showWelcome {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        Capsule()
                            .fill(colors.border.opacity(0.15))
                            .frame(height: DesignSystem.Spacing.xs - 2)

                        // Progress fill with gradient
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [colors.primary, colors.primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * viewModel.progress, height: DesignSystem.Spacing.xs - 2)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: viewModel.progress)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                }
                .frame(height: DesignSystem.Spacing.xs - 2)
                .padding(.bottom, DesignSystem.Spacing.sm)
                .transition(.opacity)
            }
        }
        .background(
            colors.background
                .shadow(color: colors.text.opacity(0.05), radius: 8, y: 2)
        )
    }

    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading {
            LoadingView()
        } else if let error = viewModel.error {
            ErrorView(error: error) {
                await viewModel.loadSurvey(slug: slug)
            }
        } else if viewModel.isComplete {
            completionView
        } else if style == .normal {
            normalWelcomeAndQuestion
        } else if showWelcome && viewModel.survey != nil {
            welcomeView
        } else if let currentNode = viewModel.currentNode {
            questionView(for: currentNode)
        } else {
            EmptyStateView(
                icon: "list.clipboard",
                title: "Survey Not Found",
                message: "This survey is no longer available."
            )
        }
    }

    private var normalWelcomeAndQuestion: some View {
        let shouldShowWelcome = showWelcome || viewModel.currentNode == nil
        return ZStack {
            if viewModel.survey != nil {
                welcomeView
                    .opacity(shouldShowWelcome ? 1 : 0)
                    .allowsHitTesting(shouldShowWelcome)
            }

            if let currentNode = viewModel.currentNode {
                questionView(for: currentNode)
                    .opacity(shouldShowWelcome ? 0 : 1)
                    .allowsHitTesting(!shouldShowWelcome)
            }
        }
        .animation(nil, value: shouldShowWelcome)
    }

    private func questionView(for node: SurveyNode) -> some View {
        Group {
            switch style {
            case .normal:
                normalQuestionView(for: node)
            case .typeform:
                typeformQuestionView(for: node)
            }
        }
    }
    
    // MARK: - Normal Style Question View
    private func normalQuestionView(for node: SurveyNode) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                progressSection
                    .frame(height: DesignSystem.Spacing.xxxl + 12) // Fixed height for progress section

                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                        // Question text with fixed minimum height
                        HStack(alignment: .top) {
                            Text(node.question)
                                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                                .foregroundColor(colors.text)
                                .fixedSize(horizontal: false, vertical: true)

                            if node.isRequired {
                                Text("*")
                                    .foregroundColor(colors.error)
                            } else {
                                // Placeholder to maintain consistent spacing
                                Text(" ")
                                    .opacity(0)
                            }
                        }
                        .frame(minHeight: DesignSystem.Spacing.xxl + 8) // Minimum height for consistency

                        answerInput(for: node, style: .normal)
                            .frame(minHeight: DesignSystem.Spacing.xxl + 16) // Minimum height for answer input
                    }

                    navigationButtons(for: node, style: .normal)
                        .frame(height: DesignSystem.Spacing.xxl + 16) // Fixed height for navigation buttons
                }
                .padding(DesignSystem.Spacing.xl)
                .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                        .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                )
            }
            .padding(DesignSystem.Spacing.xl) // Consistent padding
        }
    }
    
    // MARK: - Typeform Style Question View
    private func typeformQuestionView(for node: SurveyNode) -> some View {
        ScrollViewReader { proxy in
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    // Top anchor for scrolling
                    Color.clear
                        .frame(height: DesignSystem.BorderWidth.thin)
                        .id("questionTop")

                    // Fixed top spacing
                    Spacer()
                        .frame(height: DesignSystem.Spacing.xxxl + 8)

                    // Question number (subtle) - fixed height container
                    HStack {
                        Text("Question \(viewModel.currentQuestionNumber)")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                        Spacer()
                    }
                    .frame(height: DesignSystem.Spacing.xl - 4) // Fixed height
                    .padding(.horizontal, DesignSystem.Spacing.xxxl + 8)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                    .transition(.opacity)

                    // Main question text (large and prominent) - fixed height container
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                            Text(node.question)
                                .font(.system(size: DesignSystem.Typography.xxxl, weight: DesignSystem.Typography.bold, design: .rounded))
                                .foregroundColor(colors.text)
                                .fixedSize(horizontal: false, vertical: true)
                                .lineSpacing(DesignSystem.Spacing.xs)
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .leading)),
                                    removal: .opacity.combined(with: .move(edge: .trailing))
                                ))

                            if node.isRequired {
                                Text("Required")
                                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                                    .foregroundColor(colors.error.opacity(DesignSystem.Opacity.subtle))
                                    .transition(.opacity)
                            } else {
                                // Placeholder to maintain consistent spacing
                                Text(" ")
                                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                                    .opacity(0)
                            }
                        }

                        Spacer()
                    }
                    .frame(minHeight: DesignSystem.Spacing.xxxl + 16) // Minimum height to maintain consistency
                    .padding(.horizontal, DesignSystem.Spacing.xxxl + 8)
                    .padding(.bottom, DesignSystem.Spacing.xxxl)

                    // Answer input area - consistent spacing
                    VStack(spacing: DesignSystem.Spacing.xl) {
                        answerInput(for: node, style: .typeform)
                            .transition(.asymmetric(
                                insertion: .opacity.combined(with: .move(edge: .bottom)),
                                removal: .opacity.combined(with: .move(edge: .top))
                            ))
                    }
                    .frame(minHeight: DesignSystem.Spacing.xxxl + 20) // Minimum height for consistency
                    .padding(.horizontal, DesignSystem.Spacing.xxxl + 8)
                    .padding(.bottom, DesignSystem.Spacing.xxxl + 8)

                    // Navigation buttons (if needed) - fixed height
                    if node.questionType != .yesNo {
                        navigationButtons(for: node, style: .typeform)
                            .frame(height: DesignSystem.Spacing.xxxl + 12) // Fixed height
                            .padding(.horizontal, DesignSystem.Spacing.xxxl + 8)
                            .padding(.bottom, DesignSystem.Spacing.xxxl + 8)
                    } else {
                        // Placeholder to maintain spacing when no buttons
                        Color.clear
                            .frame(height: DesignSystem.Spacing.xxxl + 12)
                            .padding(.horizontal, DesignSystem.Spacing.xxxl + 8)
                            .padding(.bottom, DesignSystem.Spacing.xxxl + 8)
                    }

                    // Fixed bottom spacing
                    Spacer()
                        .frame(height: DesignSystem.Spacing.xxxl + 8)
                }
                .frame(maxWidth: .infinity)
            }
            .opacity(questionTransition ? 1 : 1)
            .onAppear {
                // Scroll to top when view appears
                DispatchQueue.main.asyncAfter(deadline: .now() + DesignSystem.Animation.instant) {
                    withAnimation(.easeInOut(duration: DesignSystem.Animation.slower)) {
                        proxy.scrollTo("questionTop", anchor: .top)
                    }
                }
            }
            .onChange(of: scrollToTop) { _ in
                // Scroll to top when question changes
                withAnimation(.easeInOut(duration: DesignSystem.Animation.slower)) {
                    proxy.scrollTo("questionTop", anchor: .top)
                }
            }
        }
    }
    
    private var progressSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text("Question \(viewModel.currentQuestionNumber) of \(viewModel.totalQuestions)")
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.neutral500)

                Spacer()

                Text("\(Int(viewModel.progress * 100))%")
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.primary)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(colors.border)
                        .frame(height: DesignSystem.Spacing.xs)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))

                    Rectangle()
                        .fill(colors.primary)
                        .frame(width: geometry.size.width * viewModel.progress, height: DesignSystem.Spacing.xs)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
                }
            }
            .frame(height: DesignSystem.Spacing.xs)
        }
    }

    @ViewBuilder
    private func answerInput(for node: SurveyNode, style: SurveyStyle) -> some View {
        switch node.questionType {
        case .yesNo:
            YesNoQuestionView(style: style) { answer in
                Task {
                    await viewModel.answer(.boolean(answer))
                }
            }

        case .shortAnswer:
            ShortAnswerQuestionView(text: $textAnswer, style: style)

        case .paragraph:
            ParagraphQuestionView(text: $textAnswer, style: style)

        case .multipleChoice:
            if let options = node.options {
                MultipleChoiceQuestionView(options: options, selectedOption: $selectedOption, style: style)
            }

        case .checkboxes:
            if let options = node.options {
                CheckboxesQuestionView(options: options, selectedOptions: $selectedOptions, style: style)
            }

        case .rating:
            RatingQuestionView(
                minRating: node.minRating ?? 1,
                maxRating: node.maxRating ?? 5,
                rating: $rating,
                style: style
            )
        }
    }

    @ViewBuilder
    private func navigationButtons(for node: SurveyNode, style: SurveyStyle) -> some View {
        switch style {
        case .normal:
            normalNavigationButtons(for: node)
        case .typeform:
            typeformNavigationButtons(for: node)
        }
    }
    
    private func normalNavigationButtons(for node: SurveyNode) -> some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            if viewModel.canGoBack {
                Button {
                    viewModel.goBack()
                    resetInputs()
                } label: {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)
                    .padding(DesignSystem.Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                    )
                }
            }

            if node.questionType != .yesNo {
                Button {
                    Task {
                        await submitCurrentAnswer(for: node)
                    }
                } label: {
                    HStack {
                        Text("Continue")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(.white)
                    .padding(DesignSystem.Spacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                    .shadowStyle(DesignSystem.Shadow.sm)
                }
                .disabled(!canContinue(for: node))
                .opacity(canContinue(for: node) ? DesignSystem.Opacity.full : DesignSystem.Opacity.disabled)
            }
        }
        .padding(.top, DesignSystem.Spacing.lg)
    }
    
    private func typeformNavigationButtons(for node: SurveyNode) -> some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            if viewModel.canGoBack {
                Button {
                    withAnimation(.easeInOut(duration: DesignSystem.Animation.normal)) {
                        viewModel.goBack()
                        resetInputs()
                    }
                } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                        Text("Back")
                            .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    }
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.lg - 2)
                    .background(colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                    )
                }
            }

            Button {
                Task {
                    await submitCurrentAnswer(for: node)
                }
            } label: {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text("Continue")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    Image(systemName: "arrow.right")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.xxl)
                .padding(.vertical, DesignSystem.Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(colors.primary)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                .shadowStyle(DesignSystem.Shadow.md)
            }
            .disabled(!canContinue(for: node))
            .opacity(canContinue(for: node) ? DesignSystem.Opacity.full : DesignSystem.Opacity.disabled)
        }
    }
    
    private func canContinue(for node: SurveyNode) -> Bool {
        if node.isRequired {
            switch node.questionType {
            case .yesNo:
                return true // Yes/No auto-submits
            case .shortAnswer, .paragraph:
                return !textAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            case .multipleChoice:
                return selectedOption != nil
            case .checkboxes:
                return !selectedOptions.isEmpty
            case .rating:
                return rating != nil
            }
        }
        return true
    }

    private func submitCurrentAnswer(for node: SurveyNode) async {
        let answer: SurveyAnswer

        switch node.questionType {
        case .yesNo:
            return
        case .shortAnswer, .paragraph:
            answer = .text(textAnswer)
        case .multipleChoice:
            if let selected = selectedOption {
                answer = .options([selected])
            } else {
                answer = .options([])
            }
        case .checkboxes:
            answer = .options(Array(selectedOptions))
        case .rating:
            if let r = rating {
                answer = .rating(r)
            } else {
                answer = .rating(0)
            }
        }

        await viewModel.answer(answer)
        resetInputs()
    }

    private func resetInputs() {
        textAnswer = ""
        selectedOption = nil
        selectedOptions = []
        rating = nil
    }

    private var completionView: some View {
        Group {
            switch style {
            case .normal:
                normalCompletionView
            case .typeform:
                typeformCompletionView
            }
        }
    }
    
    private var normalCompletionView: some View {
        ZStack {
            backgroundView

            VStack(spacing: DesignSystem.Spacing.xl) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: DesignSystem.Typography.xxxl * 2))
                    .foregroundColor(colors.success)
                    .symbolEffect(.bounce, value: showCompletionAnimation)
                    .scaleEffect(showCompletionAnimation ? 1.0 : 0.5)
                    .opacity(showCompletionAnimation ? 1.0 : 0.0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.1), value: showCompletionAnimation)

                Text("Thank You!")
                    .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                    .foregroundColor(colors.text)
                    .opacity(showCompletionAnimation ? 1.0 : 0.0)
                    .offset(y: showCompletionAnimation ? 0 : 20)
                    .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3), value: showCompletionAnimation)

                if let message = viewModel.resultMessage {
                    Text(message)
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.neutral500)
                        .multilineTextAlignment(.center)
                        .opacity(showCompletionAnimation ? 1.0 : 0.0)
                        .offset(y: showCompletionAnimation ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: showCompletionAnimation)
                } else {
                    Text("Your response has been submitted successfully.")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.neutral500)
                        .multilineTextAlignment(.center)
                        .opacity(showCompletionAnimation ? 1.0 : 0.0)
                        .offset(y: showCompletionAnimation ? 0 : 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: showCompletionAnimation)
                }

                Button {
                    dismiss()
                } label: {
                    Text("Done")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.cardBackground)
                        .padding(DesignSystem.Spacing.lg)
                        .frame(maxWidth: .infinity)
                        .background(colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                        .shadowStyle(DesignSystem.Shadow.sm)
                }
                .opacity(showCompletionAnimation ? 1.0 : 0.0)
                .scaleEffect(showCompletionAnimation ? 1.0 : 0.9)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.7), value: showCompletionAnimation)
                .padding(.top, DesignSystem.Spacing.lg)
            }
            .padding(DesignSystem.Spacing.lg)
            .frame(maxWidth: .infinity)
            .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                    .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
            )
            .padding(DesignSystem.Spacing.lg)
        }
    }
    
    private var typeformCompletionView: some View {
        VStack(spacing: DesignSystem.Spacing.xxl) {
            Spacer()

            VStack(spacing: DesignSystem.Spacing.xl) {
                ZStack {
                    // Animated background glow
                    Circle()
                        .fill(colors.success.opacity(0.2))
                        .frame(width: 140, height: 140)
                        .scaleEffect(showCompletionAnimation ? 1.2 : 0.8)
                        .opacity(showCompletionAnimation ? 0.0 : 0.5)
                        .blur(radius: 30)
                        .animation(.easeOut(duration: 1.0).delay(0.2), value: showCompletionAnimation)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: DesignSystem.Typography.xxxl * 2.5))
                        .foregroundColor(colors.success)
                        .symbolEffect(.bounce, value: showCompletionAnimation)
                        .scaleEffect(showCompletionAnimation ? 1.0 : 0.3)
                        .opacity(showCompletionAnimation ? 1.0 : 0.0)
                        .animation(.spring(response: 0.7, dampingFraction: 0.5).delay(0.1), value: showCompletionAnimation)
                }

                Text("Thank You!")
                    .font(.system(size: DesignSystem.Typography.xxxl + 4, weight: DesignSystem.Typography.bold, design: .rounded))
                    .foregroundColor(colors.text)
                    .opacity(showCompletionAnimation ? 1.0 : 0.0)
                    .offset(y: showCompletionAnimation ? 0 : 30)
                    .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.4), value: showCompletionAnimation)

                if let message = viewModel.resultMessage {
                    Text(message)
                        .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                        .multilineTextAlignment(.center)
                        .lineSpacing(DesignSystem.Spacing.xs)
                        .padding(.horizontal, DesignSystem.Spacing.xxxl + 8)
                        .opacity(showCompletionAnimation ? 1.0 : 0.0)
                        .offset(y: showCompletionAnimation ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.6), value: showCompletionAnimation)
                } else {
                    Text("Your response has been submitted successfully.")
                        .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                        .multilineTextAlignment(.center)
                        .lineSpacing(DesignSystem.Spacing.xs)
                        .padding(.horizontal, DesignSystem.Spacing.xxxl + 8)
                        .opacity(showCompletionAnimation ? 1.0 : 0.0)
                        .offset(y: showCompletionAnimation ? 0 : 20)
                        .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.6), value: showCompletionAnimation)
                }
            }

            Spacer()

            Button {
                dismiss()
            } label: {
                Text("Done")
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignSystem.Spacing.xxxl)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .background(
                        LinearGradient(
                            colors: [colors.primary, colors.primary.opacity(0.9)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .shadowStyle(DesignSystem.Shadow.lg)
            }
            .opacity(showCompletionAnimation ? 1.0 : 0.0)
            .scaleEffect(showCompletionAnimation ? 1.0 : 0.8)
            .animation(.spring(response: 0.7, dampingFraction: 0.7).delay(0.9), value: showCompletionAnimation)
            .padding(.bottom, DesignSystem.Spacing.xxxl + 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
    }

    // MARK: - Welcome View
    private var welcomeView: some View {
        Group {
            switch style {
            case .normal:
                normalWelcomeView
            case .typeform:
                typeformWelcomeView
            }
        }
    }

    private var normalWelcomeView: some View {
        ScrollView {
            VStack(spacing: DesignSystem.Spacing.xxl) {
                Spacer()
                    .frame(height: DesignSystem.Spacing.xxl)

                // Hero section
                VStack(spacing: DesignSystem.Spacing.lg) {
                    // Icon with gradient background
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [colors.primary.opacity(0.2), colors.primary.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 96, height: 96)

                        Image(systemName: "doc.text.fill")
                            .font(.system(size: DesignSystem.Typography.xxxl, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.primary)
                    }
                    .shadowStyle(DesignSystem.Shadow.lg)

                    if let survey = viewModel.survey {
                        Text(survey.name)
                            .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold))
                            .foregroundColor(colors.text)
                            .multilineTextAlignment(.center)

                        if let description = survey.description {
                            Text(description)
                                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                                .foregroundColor(colors.neutral500)
                                .multilineTextAlignment(.center)
                                .lineSpacing(DesignSystem.Spacing.xs)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)

                // Survey info cards
                VStack(spacing: DesignSystem.Spacing.md) {
                    infoCard(
                        icon: "clock.fill",
                        title: "Quick & Easy",
                        description: "\(viewModel.totalQuestions) questions"
                    )

                    infoCard(
                        icon: "lock.fill",
                        title: "Anonymous",
                        description: "Your responses are private"
                    )
                }
                    .padding(.horizontal, DesignSystem.Spacing.xl)

                Spacer()

                // Start button
                Button {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) {
                        showWelcome = false
                    }
                } label: {
                    HStack {
                        Text("Start Survey")
                            .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .background(colors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                    .shadowStyle(DesignSystem.Shadow.md)
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.xxl)
            }
        }
        .background(backgroundView)
    }

    private var typeformWelcomeView: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: DesignSystem.Spacing.xxxl) {
                // Animated icon
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [colors.primary.opacity(0.15), colors.primary.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .blur(radius: 20)

                    Circle()
                        .fill(colors.cardBackground)
                        .frame(width: 100, height: 100)
                        .shadowStyle(DesignSystem.Shadow.xl)

                    Image(systemName: "doc.text.fill")
                        .font(.system(size: DesignSystem.Typography.xxxl + 8, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.primary)
                        .symbolEffect(.bounce, value: viewModel.survey != nil)
                }

                if let survey = viewModel.survey {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        Text(survey.name)
                            .font(.system(size: DesignSystem.Typography.xxxl, weight: DesignSystem.Typography.bold, design: .rounded))
                            .foregroundColor(colors.text)
                            .multilineTextAlignment(.center)
                            .lineSpacing(DesignSystem.Spacing.xs)

                        if let description = survey.description {
                            Text(description)
                                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.regular))
                                .foregroundColor(colors.neutral500)
                                .multilineTextAlignment(.center)
                                .lineSpacing(DesignSystem.Spacing.sm)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xxxl + 8)
                }

                // Quick stats
                HStack(spacing: DesignSystem.Spacing.xxl) {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Text("\(viewModel.totalQuestions)")
                            .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold, design: .rounded))
                            .foregroundColor(colors.primary)

                        Text("Questions")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                            .foregroundColor(colors.neutral500)
                    }

                    Rectangle()
                        .fill(colors.border.opacity(0.3))
                        .frame(width: 1, height: 48)

                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "lock.fill")
                            .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.bold))
                            .foregroundColor(colors.success)

                        Text("Anonymous")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                            .foregroundColor(colors.neutral500)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xxxl)
                .padding(.vertical, DesignSystem.Spacing.xl)
                .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                        .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                )
                .shadowStyle(DesignSystem.Shadow.sm)
            }

            Spacer()

            // Start button
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    showWelcome = false
                }
            } label: {
                HStack(spacing: DesignSystem.Spacing.md) {
                    Text("Let's Begin")
                        .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))

                    Image(systemName: "arrow.right.circle.fill")
                        .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, DesignSystem.Spacing.xxxl + 8)
                .padding(.vertical, DesignSystem.Spacing.lg + 2)
                .background(
                    LinearGradient(
                        colors: [colors.primary, colors.primary.opacity(0.9)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
                .shadowStyle(DesignSystem.Shadow.lg)
            }
            .padding(.bottom, DesignSystem.Spacing.xxxl + 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundView)
    }

    private func infoCard(icon: String, title: String, description: String) -> some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(colors.primary.opacity(0.1))
                    .frame(width: 48, height: 48)

                Image(systemName: icon)
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.primary)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs - 2) {
                Text(title)
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                Text(description)
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.neutral500)
            }

            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground, in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
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
}
