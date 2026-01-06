import SwiftUI

public struct EmptyStateView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        icon: String = "tray",
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [colors.text.opacity(0.15), colors.text.opacity(0.08)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            Text(title)
                .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                .foregroundColor(colors.text)

            Text(message)
                .font(.system(size: DesignSystem.Typography.sm))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xl)

            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
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
