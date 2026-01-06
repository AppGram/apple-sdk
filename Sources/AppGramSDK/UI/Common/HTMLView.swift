import SwiftUI
import WebKit

/// Preference key to communicate height from WKWebView
private struct WebViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat = 100
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

/// A SwiftUI view that renders HTML content using WKWebView with proper styling
public struct HTMLView: UIViewRepresentable {
    let htmlContent: String
    let textColor: UIColor
    let backgroundColor: UIColor
    @Binding var contentHeight: CGFloat
    
    public init(htmlContent: String, textColor: UIColor = .label, backgroundColor: UIColor = .systemBackground, contentHeight: Binding<CGFloat> = .constant(100)) {
        self.htmlContent = htmlContent
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self._contentHeight = contentHeight
    }
    
    public func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.dataDetectorTypes = []
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.isScrollEnabled = false // Disable internal scrolling, let parent ScrollView handle it
        webView.scrollView.bounces = false
        webView.navigationDelegate = context.coordinator
        
        return webView
    }
    
    public func updateUIView(_ webView: WKWebView, context: Context) {
        let htmlString = """
        <!DOCTYPE html>
        <html>
        <head>
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <style>
                * {
                    margin: 0;
                    padding: 0;
                    box-sizing: border-box;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: \(cssColor(from: textColor));
                    background-color: \(cssColor(from: backgroundColor));
                    padding: 0;
                    word-wrap: break-word;
                }
                h1, h2, h3, h4, h5, h6 {
                    margin-top: 1.5em;
                    margin-bottom: 0.5em;
                    font-weight: 600;
                    line-height: 1.2;
                }
                h1 { font-size: 2em; }
                h2 { font-size: 1.5em; }
                h3 { font-size: 1.25em; }
                h4 { font-size: 1.1em; }
                p {
                    margin: 1em 0;
                }
                ul, ol {
                    margin: 1em 0;
                    padding-left: 2em;
                }
                li {
                    margin: 0.5em 0;
                }
                code {
                    font-family: 'Menlo', 'Monaco', 'Courier New', monospace;
                    background-color: rgba(0, 0, 0, 0.05);
                    padding: 2px 6px;
                    border-radius: 3px;
                    font-size: 0.9em;
                }
                pre {
                    background-color: rgba(0, 0, 0, 0.05);
                    padding: 1em;
                    border-radius: 6px;
                    overflow-x: auto;
                    margin: 1em 0;
                }
                pre code {
                    background-color: transparent;
                    padding: 0;
                }
                blockquote {
                    border-left: 4px solid rgba(0, 0, 0, 0.2);
                    padding-left: 1em;
                    margin: 1em 0;
                    color: rgba(0, 0, 0, 0.7);
                }
                a {
                    color: \(cssColor(from: textColor));
                    text-decoration: underline;
                }
                img {
                    max-width: 100%;
                    height: auto;
                    border-radius: 6px;
                    margin: 1em 0;
                }
                table {
                    width: 100%;
                    border-collapse: collapse;
                    margin: 1em 0;
                }
                th, td {
                    border: 1px solid rgba(0, 0, 0, 0.1);
                    padding: 0.5em;
                    text-align: left;
                }
                th {
                    background-color: rgba(0, 0, 0, 0.05);
                    font-weight: 600;
                }
            </style>
        </head>
        <body>
            \(htmlContent)
        </body>
        </html>
        """
        
        webView.loadHTMLString(htmlString, baseURL: nil)
    }
    
    public func makeCoordinator() -> Coordinator {
        let coordinator = Coordinator()
        coordinator.heightBinding = $contentHeight
        return coordinator
    }
    
    public class Coordinator: NSObject, WKNavigationDelegate {
        var heightBinding: Binding<CGFloat>?
        
        func updateHeight(for webView: WKWebView) {
            let script = """
                (function() {
                    var height = Math.max(
                        document.body.scrollHeight,
                        document.body.offsetHeight,
                        document.documentElement.clientHeight,
                        document.documentElement.scrollHeight,
                        document.documentElement.offsetHeight
                    );
                    return height;
                })();
            """
            
            webView.evaluateJavaScript(script) { [weak self] result, error in
                if let height = result as? CGFloat, height > 0 {
                    DispatchQueue.main.async {
                        self?.heightBinding?.wrappedValue = height
                    }
                }
            }
        }
        
        public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            // Wait a bit for content to render, then get height
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateHeight(for: webView)
            }
        }
    }
    
    private func cssColor(from color: UIColor) -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        return String(format: "rgba(%d, %d, %d, %.2f)",
                     Int(red * 255),
                     Int(green * 255),
                     Int(blue * 255),
                     alpha)
    }
}

/// A SwiftUI view that renders HTML content with proper theming
public struct HTMLContentView: View {
    @Environment(\.colorScheme) private var colorScheme
    let htmlContent: String
    let textColor: Color
    let backgroundColor: Color
    @State private var contentHeight: CGFloat = 200
    
    public init(htmlContent: String, textColor: Color? = nil, backgroundColor: Color? = nil) {
        self.htmlContent = htmlContent
        self.textColor = textColor ?? .primary
        self.backgroundColor = backgroundColor ?? .clear
    }
    
    public var body: some View {
        HTMLView(
            htmlContent: htmlContent,
            textColor: UIColor(textColor),
            backgroundColor: UIColor(backgroundColor),
            contentHeight: $contentHeight
        )
        .frame(height: max(contentHeight, 200))
    }
}
