import SwiftUI
import MarkdownUI

/// A view that automatically chooses between Markdown and HTML rendering based on content
struct BlogContentView: View {
    let content: String
    let theme: AppGramTheme

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let colors = theme.resolvedColors(for: colorScheme)

        if isHTML(content) {
            HTMLContentView(
                htmlContent: content,
                textColor: colors.text,
                backgroundColor: .clear
            )
        } else {
            Markdown(content)
                .markdownTextStyle {
                    ForegroundColor(colors.text)
                }
                .markdownBlockStyle(\.heading1) { configuration in
                    configuration.label
                        .markdownTextStyle {
                            FontWeight(.bold)
                            FontSize(24)
                        }
                }
                .markdownBlockStyle(\.heading2) { configuration in
                    configuration.label
                        .markdownTextStyle {
                            FontWeight(.semibold)
                            FontSize(20)
                        }
                }
                .markdownBlockStyle(\.heading3) { configuration in
                    configuration.label
                        .markdownTextStyle {
                            FontWeight(.semibold)
                            FontSize(18)
                        }
                }
        }
    }

    private func isHTML(_ text: String) -> Bool {
        // Check for common HTML tags
        let htmlPattern = "<\\s*(p|div|span|h[1-6]|ul|ol|li|a|img|br|hr|table|tr|td|th|strong|em|b|i|pre|code|blockquote)[^>]*>"
        return text.range(of: htmlPattern, options: .regularExpression, range: nil, locale: nil) != nil
    }
}
