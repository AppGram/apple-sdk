import SwiftUI

/// A prompt view that encourages users to take a survey.
///
/// This view displays a message encouraging survey participation and a button
/// that opens the full survey view when tapped.
struct SurveyPromptView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingSurvey = false

    let slug: String
    let style: SurveyStyle

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("We'd love your feedback!")
                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            Text("Help us improve by taking a quick survey")
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

            PrimaryButton("Take Survey") {
                showingSurvey = true
            }
        }
        .sheet(isPresented: $showingSurvey) {
            if let surveyView = try? AppGramSDK.shared.surveyView(slug: slug, style: style) {
                AnyView(surveyView)
            }
        }
    }
}
