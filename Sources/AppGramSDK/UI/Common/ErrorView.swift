import SwiftUI

public struct ErrorView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let error: AppGramError
    let retryAction: (() async -> Void)?
    let presentation: Presentation

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        error: AppGramError,
        retryAction: (() async -> Void)? = nil,
        presentation: Presentation = .full
    ) {
        self.error = error
        self.retryAction = retryAction
        self.presentation = presentation
    }

    public var body: some View {
        ZStack {
            backgroundView
            contentCard
        }
    }

    private var contentCard: some View {
        VStack(spacing: DesignSystem.Spacing.xl) {
            ZStack {
                Circle()
                    .fill(colors.error.opacity(0.12))
                    .frame(width: 120, height: 120)

                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [colors.error, colors.error.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: DesignSystem.Spacing.sm) {
                Text("We hit a snag")
                    .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold, design: .serif))
                    .foregroundColor(colors.text)

                Text("Please try again or come back in a moment.")
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.neutral500)
                    .multilineTextAlignment(.center)
            }

            Text(error.localizedDescription)
                .font(.system(size: DesignSystem.Typography.sm))
                .foregroundColor(colors.neutral500)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignSystem.Spacing.xxl)

            if let retryAction = retryAction {
                Button {
                    Task { await retryAction() }
                } label: {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "arrow.clockwise")
                        Text("Try Again")
                    }
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.cardBackground)
                    .padding(.horizontal, DesignSystem.Spacing.xxl)
                    .padding(.vertical, DesignSystem.Spacing.lg)
                    .background(colors.primary)
                    .clipShape(Capsule())
                    .shadowStyle(DesignSystem.Shadow.md)
                }
                .padding(.top, DesignSystem.Spacing.sm)
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                .offset(x: 140, y: -120)
        )
        .ignoresSafeArea()
    }
}

extension ErrorView {
    public enum Presentation: Sendable {
        case full
    }
}
