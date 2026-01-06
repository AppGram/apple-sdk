import SwiftUI

/// A prompt view that encourages users to provide feedback.
///
/// This view displays a simple message encouraging feedback and a button
/// that opens the full feedback view when tapped.
struct FeedbackPromptView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @State private var showingFeedback = false

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("Share Your Feedback")
                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            Text("We'd love to hear your thoughts!")
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

            PrimaryButton("Give Feedback") {
                showingFeedback = true
            }
        }
        .sheet(isPresented: $showingFeedback) {
            if let feedbackView = try? AppGramSDK.shared.feedbackView() {
                AnyView(feedbackView)
            }
        }
    }
}
