import SwiftUI

public struct LoadingView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init() {}

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: colors.primary))
                .scaleEffect(1.2)
            Text("Loading...")
                .font(.system(size: DesignSystem.Typography.sm))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
    }
}
