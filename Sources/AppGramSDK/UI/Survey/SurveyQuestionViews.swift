import SwiftUI

public struct YesNoQuestionView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedAnswer: Bool?

    let style: SurveyStyle
    let onAnswer: (Bool) -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(style: SurveyStyle = .normal, onAnswer: @escaping (Bool) -> Void) {
        self.style = style
        self.onAnswer = onAnswer
    }

    public var body: some View {
        switch style {
        case .normal:
            normalStyle
        case .typeform:
            typeformStyle
        }
    }
    
    private var normalStyle: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            Button {
                onAnswer(true)
            } label: {
                Text("Yes")
                    .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .background(colors.success)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            }

            Button {
                onAnswer(false)
            } label: {
                Text("No")
                    .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .background(colors.error)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            }
        }
    }
    
    private var typeformStyle: some View {
        HStack(spacing: DesignSystem.Spacing.xl) {
            Button {
                withAnimation(DesignSystem.Animation.spring) {
                    selectedAnswer = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + DesignSystem.Animation.normal) {
                    onAnswer(true)
                }
            } label: {
                Text("Yes")
                    .font(.system(size: DesignSystem.Typography.xl, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xl)
                    .background(selectedAnswer == true ? colors.success : colors.success.opacity(DesignSystem.Opacity.subtle))
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
                    .shadowStyle(selectedAnswer == true ? DesignSystem.Shadow.lg : DesignSystem.Shadow.none)
                    .scaleEffect(selectedAnswer == true ? 0.95 : 1.0)
            }
            .buttonStyle(.plain)

            Button {
                withAnimation(DesignSystem.Animation.spring) {
                    selectedAnswer = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + DesignSystem.Animation.normal) {
                    onAnswer(false)
                }
            } label: {
                Text("No")
                    .font(.system(size: DesignSystem.Typography.xl, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, DesignSystem.Spacing.xl)
                    .background(selectedAnswer == false ? colors.error : colors.error.opacity(DesignSystem.Opacity.subtle))
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
                    .shadowStyle(selectedAnswer == false ? DesignSystem.Shadow.lg : DesignSystem.Shadow.none)
                    .scaleEffect(selectedAnswer == false ? 0.95 : 1.0)
            }
            .buttonStyle(.plain)
        }
    }
}

public struct ShortAnswerQuestionView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool

    let style: SurveyStyle
    @Binding var text: String

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(text: Binding<String>, style: SurveyStyle = .normal) {
        self.style = style
        self._text = text
    }

    public var body: some View {
        switch style {
        case .normal:
            normalStyle
        case .typeform:
            typeformStyle
        }
    }
    
    private var normalStyle: some View {
        TextField("Your answer", text: $text)
            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
            .foregroundColor(colors.text)
            .textFieldStyle(.plain)
            .padding(DesignSystem.Spacing.lg)
            .background(colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
            )
    }

    private var typeformStyle: some View {
        TextField("Type your answer", text: $text)
            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
            .foregroundColor(colors.text)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .background(colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                    .strokeBorder(isFocused ? colors.primary : colors.neutral200.opacity(DesignSystem.Opacity.muted), lineWidth: isFocused ? DesignSystem.BorderWidth.thick : DesignSystem.BorderWidth.thin)
            )
            .focused($isFocused)
            .shadowStyle(isFocused ? DesignSystem.Shadow.sm : DesignSystem.Shadow.xs)
            .animation(DesignSystem.Animation.easeInOut, value: isFocused)
    }
}

public struct ParagraphQuestionView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @FocusState private var isFocused: Bool

    let style: SurveyStyle
    @Binding var text: String

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(text: Binding<String>, style: SurveyStyle = .normal) {
        self.style = style
        self._text = text
    }

    public var body: some View {
        switch style {
        case .normal:
            normalStyle
        case .typeform:
            typeformStyle
        }
    }
    
    private var normalStyle: some View {
        TextEditor(text: $text)
            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
            .foregroundColor(colors.text)
            .frame(minHeight: 120)
            .padding(DesignSystem.Spacing.sm)
            .scrollContentBackground(.hidden)
            .background(colors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                    .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
            )
    }

    private var typeformStyle: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text("Type your answer")
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.disabled))
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.lg)
            }

            TextEditor(text: $text)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text)
                .frame(minHeight: 160)
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.vertical, DesignSystem.Spacing.md)
                .scrollContentBackground(.hidden)
                .background(colors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                        .strokeBorder(isFocused ? colors.primary : colors.neutral200.opacity(DesignSystem.Opacity.muted), lineWidth: isFocused ? DesignSystem.BorderWidth.thick : DesignSystem.BorderWidth.thin)
                )
                .focused($isFocused)
                .shadowStyle(isFocused ? DesignSystem.Shadow.sm : DesignSystem.Shadow.xs)
                .animation(DesignSystem.Animation.easeInOut, value: isFocused)
        }
    }
}

public struct MultipleChoiceQuestionView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let options: [NodeOption]
    let style: SurveyStyle
    @Binding var selectedOption: String?

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(options: [NodeOption], selectedOption: Binding<String?>, style: SurveyStyle = .normal) {
        self.options = options
        self.style = style
        self._selectedOption = selectedOption
    }

    public var body: some View {
        switch style {
        case .normal:
            normalStyle
        case .typeform:
            typeformStyle
        }
    }
    
    private var normalStyle: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(options) { option in
                Button {
                    selectedOption = option.id
                } label: {
                    HStack {
                        Circle()
                            .strokeBorder(selectedOption == option.id ? colors.primary : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thick)
                            .background(
                                Circle()
                                    .fill(selectedOption == option.id ? colors.primary : Color.clear)
                                    .padding(DesignSystem.Spacing.xs)
                            )
                            .frame(width: 24, height: 24)

                        Text(option.label)
                            .foregroundColor(colors.text)

                        Spacer()
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .background(selectedOption == option.id ? colors.primary.opacity(DesignSystem.Opacity.disabled) : colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .strokeBorder(selectedOption == option.id ? colors.primary : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var typeformStyle: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(options) { option in
                Button {
                    withAnimation(DesignSystem.Animation.spring) {
                        selectedOption = option.id
                    }
                } label: {
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        ZStack {
                            Circle()
                                .strokeBorder(selectedOption == option.id ? colors.primary : colors.neutral200.opacity(DesignSystem.Opacity.disabled), lineWidth: DesignSystem.BorderWidth.thick)
                                .frame(width: 28, height: 28)

                            if selectedOption == option.id {
                                Circle()
                                    .fill(colors.primary)
                                    .frame(width: 16, height: 16)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }

                        Text(option.label)
                            .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.regular))
                            .foregroundColor(colors.text)
                            .multilineTextAlignment(.leading)

                        Spacer()

                        if selectedOption == option.id {
                            Image(systemName: "checkmark")
                                .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                                .foregroundColor(colors.primary)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .background(selectedOption == option.id ? colors.primary.opacity(DesignSystem.Opacity.disabled) : colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                            .strokeBorder(selectedOption == option.id ? colors.primary : colors.neutral200.opacity(DesignSystem.Opacity.muted), lineWidth: selectedOption == option.id ? DesignSystem.BorderWidth.thick : DesignSystem.BorderWidth.thin)
                    )
                    .shadowStyle(selectedOption == option.id ? DesignSystem.Shadow.sm : DesignSystem.Shadow.xs)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

public struct CheckboxesQuestionView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let options: [NodeOption]
    let style: SurveyStyle
    @Binding var selectedOptions: Set<String>

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(options: [NodeOption], selectedOptions: Binding<Set<String>>, style: SurveyStyle = .normal) {
        self.options = options
        self.style = style
        self._selectedOptions = selectedOptions
    }

    public var body: some View {
        switch style {
        case .normal:
            normalStyle
        case .typeform:
            typeformStyle
        }
    }
    
    private var normalStyle: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(options) { option in
                Button {
                    if selectedOptions.contains(option.id) {
                        selectedOptions.remove(option.id)
                    } else {
                        selectedOptions.insert(option.id)
                    }
                } label: {
                    HStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                            .strokeBorder(selectedOptions.contains(option.id) ? colors.primary : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thick)
                            .background(
                                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                                    .fill(selectedOptions.contains(option.id) ? colors.primary : Color.clear)
                            )
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                                    .opacity(selectedOptions.contains(option.id) ? DesignSystem.Opacity.full : DesignSystem.Opacity.disabled)
                            )
                            .frame(width: 24, height: 24)

                        Text(option.label)
                            .foregroundColor(colors.text)

                        Spacer()
                    }
                    .padding(DesignSystem.Spacing.lg)
                    .background(selectedOptions.contains(option.id) ? colors.primary.opacity(DesignSystem.Opacity.disabled) : colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .strokeBorder(selectedOptions.contains(option.id) ? colors.primary : colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var typeformStyle: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            ForEach(options) { option in
                Button {
                    withAnimation(DesignSystem.Animation.spring) {
                        if selectedOptions.contains(option.id) {
                            selectedOptions.remove(option.id)
                        } else {
                            selectedOptions.insert(option.id)
                        }
                    }
                } label: {
                    HStack(spacing: DesignSystem.Spacing.lg) {
                        ZStack {
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .strokeBorder(selectedOptions.contains(option.id) ? colors.primary : colors.neutral200.opacity(DesignSystem.Opacity.disabled), lineWidth: DesignSystem.BorderWidth.thick)
                                .frame(width: 28, height: 28)

                            if selectedOptions.contains(option.id) {
                                Image(systemName: "checkmark")
                                    .font(.system(size: DesignSystem.Typography.sm, weight: .bold))
                                    .foregroundColor(.white)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .background(
                            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                                .fill(selectedOptions.contains(option.id) ? colors.primary : Color.clear)
                        )

                        Text(option.label)
                            .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.regular))
                            .foregroundColor(colors.text)
                            .multilineTextAlignment(.leading)

                        Spacer()
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .background(selectedOptions.contains(option.id) ? colors.primary.opacity(DesignSystem.Opacity.disabled) : colors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                            .strokeBorder(selectedOptions.contains(option.id) ? colors.primary : colors.neutral200.opacity(DesignSystem.Opacity.muted), lineWidth: selectedOptions.contains(option.id) ? DesignSystem.BorderWidth.thick : DesignSystem.BorderWidth.thin)
                    )
                    .shadowStyle(selectedOptions.contains(option.id) ? DesignSystem.Shadow.sm : DesignSystem.Shadow.xs)
                }
                .buttonStyle(.plain)
            }
        }
    }
}

public struct RatingQuestionView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let minRating: Int
    let maxRating: Int
    let style: SurveyStyle
    @Binding var rating: Int?

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(minRating: Int, maxRating: Int, rating: Binding<Int?>, style: SurveyStyle = .normal) {
        self.minRating = minRating
        self.maxRating = maxRating
        self.style = style
        self._rating = rating
    }

    public var body: some View {
        switch style {
        case .normal:
            normalStyle
        case .typeform:
            typeformStyle
        }
    }
    
    private var normalStyle: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            ForEach(minRating...maxRating, id: \.self) { value in
                Button {
                    rating = value
                } label: {
                    Image(systemName: value <= (rating ?? 0) ? "star.fill" : "star")
                        .font(.title)
                        .foregroundColor(value <= (rating ?? 0) ? colors.warning : colors.neutral200)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var typeformStyle: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            ForEach(minRating...maxRating, id: \.self) { value in
                Button {
                    withAnimation(DesignSystem.Animation.spring) {
                        rating = value
                    }
                } label: {
                    VStack(spacing: DesignSystem.Spacing.sm) {
                        ZStack {
                            Circle()
                                .fill(value <= (rating ?? 0) ? colors.primary.opacity(DesignSystem.Opacity.disabled) : colors.cardBackground)
                                .frame(width: 64, height: 64)

                            Text("\(value)")
                                .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold, design: .rounded))
                                .foregroundColor(value <= (rating ?? 0) ? colors.primary : colors.text.opacity(DesignSystem.Opacity.muted))
                        }
                        .overlay(
                            Circle()
                                .strokeBorder(value <= (rating ?? 0) ? colors.primary : colors.neutral200.opacity(DesignSystem.Opacity.disabled), lineWidth: value <= (rating ?? 0) ? DesignSystem.BorderWidth.thick : DesignSystem.BorderWidth.thin)
                        )
                        .shadowStyle(value <= (rating ?? 0) ? DesignSystem.Shadow.sm : DesignSystem.Shadow.xs)
                        .scaleEffect(value <= (rating ?? 0) ? 1.05 : 1.0)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
