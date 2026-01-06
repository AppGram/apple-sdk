import SwiftUI

public struct ErrorView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let error: AppGramError
    let retryAction: (() async -> Void)?

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(error: AppGramError, retryAction: (() async -> Void)? = nil) {
        self.error = error
        self.retryAction = retryAction
    }

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 56))
                .foregroundColor(colors.error)
                .symbolRenderingMode(.hierarchical)

            Text("Something went wrong")
                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            Text(error.localizedDescription)
                .font(.system(size: DesignSystem.Typography.sm))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)

            if let retryAction = retryAction {
                Button {
                    Task { await retryAction() }
                } label: {
                    Text("Try Again")
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, DesignSystem.Spacing.xl)
                        .padding(.vertical, DesignSystem.Spacing.md)
                        .background(colors.primary)
                        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                        .shadowStyle(DesignSystem.Shadow.md)
                }
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(colors.background)
    }
}
