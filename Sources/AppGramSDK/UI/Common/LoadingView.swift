import SwiftUI

public struct LoadingView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init() {}

    public var body: some View {
        ZStack {
            backgroundView

            VStack(spacing: DesignSystem.Spacing.lg) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: colors.primary))
                    .scaleEffect(1.3)

                Text("Loading")
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.medium))
                    .foregroundColor(colors.text)

                Text("Hang tight while we pull everything together.")
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.neutral500)
                    .multilineTextAlignment(.center)
            }
            .padding(DesignSystem.Spacing.xl)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .offset(x: 120, y: -120)
        )
        .ignoresSafeArea()
    }
}
