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
        ZStack {
            backgroundView

            VStack(spacing: DesignSystem.Spacing.xl) {
                Image(systemName: icon)
                    .font(.system(size: 56))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [colors.neutral500, colors.neutral300],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text(title)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                Text(message)
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.neutral500)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DesignSystem.Spacing.xl)

                if let actionTitle = actionTitle, let action = action {
                    Button(action: action) {
                        Text(actionTitle)
                            .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.medium))
                            .foregroundColor(colors.cardBackground)
                            .padding(.horizontal, DesignSystem.Spacing.xl)
                            .padding(.vertical, DesignSystem.Spacing.md)
                            .background(colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md))
                            .shadowStyle(DesignSystem.Shadow.md)
                    }
                    .padding(.top, DesignSystem.Spacing.sm)
                }
            }
            .padding(DesignSystem.Spacing.xl)
            .frame(maxWidth: .infinity)
            .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                    .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
            )
            .padding(DesignSystem.Spacing.lg)
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [colors.background, colors.neutral100],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Circle()
                .fill(colors.neutral200.opacity(0.35))
                .frame(width: 220, height: 220)
                .offset(x: -140, y: -120)
        )
        .ignoresSafeArea()
    }
}
