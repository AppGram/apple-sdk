import SwiftUI

/// A bottom banner popup view that slides up from the bottom of the screen.
///
/// This view displays popup content in a card that animates up from the bottom
/// with a spring animation. It includes a close button and optional snooze button.
struct BottomBannerView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @State private var offset: CGFloat = 500

    let content: PopupContent?
    let configuration: PopupConfiguration
    let onDismiss: () -> Void
    let onSnooze: () -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        VStack {
            Spacer()

            VStack(spacing: 0) {
                // Close button
                HStack {
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.lg)
                .padding(.top, DesignSystem.Spacing.md)

                // Content
                PopupContentView(content: content)
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.vertical, DesignSystem.Spacing.md)

                // Action buttons
                if configuration.snoozeSettings.enabled {
                    HStack(spacing: DesignSystem.Spacing.md) {
                        Button(configuration.snoozeSettings.buttonTitle) {
                            onSnooze()
                        }
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(colors.text.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.md)
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                }
            }
            .background(colors.cardBackground)
            .cornerRadius(DesignSystem.CornerRadius.lg)
            .layeredShadow()
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .offset(y: offset)
        }
        .onAppear {
            withAnimation(DesignSystem.Animation.spring) {
                offset = 0
            }
        }
    }
}
