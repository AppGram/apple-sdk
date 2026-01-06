import SwiftUI

/// A content renderer for popup content.
///
/// This view switches between different popup content types (survey, feedback, custom)
/// and renders the appropriate view for each type.
struct PopupContentView: View {
    let content: PopupContent?

    var body: some View {
        if let content = content {
            switch content {
            case .survey(let slug, let style):
                SurveyPromptView(slug: slug, style: style)

            case .feedback:
                FeedbackPromptView()

            case .customView(let viewBuilder):
                viewBuilder()
            }
        } else {
            EmptyView()
        }
    }
}
