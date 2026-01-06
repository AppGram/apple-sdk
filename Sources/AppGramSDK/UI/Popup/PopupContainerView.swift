import SwiftUI

/// The main container view for displaying popups.
///
/// This view observes a PopupManager and presents popups in the configured
/// presentation style (bottom banner or sheet modal).
public struct PopupContainerView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @ObservedObject var manager: PopupManager

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public var body: some View {
        ZStack {
            // Only show banner if using bottom banner style
            if manager.isPresented && manager.configuration.presentationStyle == .bottomBanner {
                BottomBannerView(
                    content: manager.currentContent,
                    configuration: manager.configuration,
                    onDismiss: {
                        manager.dismiss()
                    },
                    onSnooze: {
                        manager.snooze()
                    }
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .sheet(isPresented: Binding(
            get: { manager.isPresented && manager.configuration.presentationStyle == .sheet },
            set: { if !$0 { manager.dismiss() } }
        )) {
            // Sheet content
            NavigationStack {
                VStack(spacing: 0) {
                    // Content
                    PopupContentView(content: manager.currentContent)
                        .padding(DesignSystem.Spacing.lg)

                    Spacer()

                    // Action buttons at bottom
                    if manager.configuration.snoozeSettings.enabled {
                        Button(manager.configuration.snoozeSettings.buttonTitle) {
                            manager.snooze()
                        }
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                        .padding(.horizontal, DesignSystem.Spacing.lg)
                        .padding(.vertical, DesignSystem.Spacing.sm)
                        .background(colors.text.opacity(0.1))
                        .cornerRadius(DesignSystem.CornerRadius.md)
                        .padding(.bottom, DesignSystem.Spacing.lg)
                    }
                }
                .background(colors.background)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            manager.dismiss()
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(colors.text.opacity(0.6))
                        }
                    }
                }
            }
            .appGramTheme(theme)
        }
    }
}
