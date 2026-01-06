import SwiftUI
import MarkdownUI

public struct MarkdownView: View {
    let content: String

    public init(_ content: String) {
        self.content = content
    }

    public var body: some View {
        Markdown(content)
            .markdownTextStyle {
                FontSize(15)
            }
            .markdownBlockStyle(\.codeBlock) { configuration in
                configuration.label
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .markdownTextStyle {
                        FontFamilyVariant(.monospaced)
                        FontSize(14)
                    }
            }
    }
}
