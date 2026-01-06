import SwiftUI

/// Primary action button with design system styling and animations.
///
/// Features shadcn-inspired subtle shadows and iOS 26 spring animations.
///
/// ## Example
/// ```swift
/// PrimaryButton("Submit", isLoading: isSubmitting) {
///     // Handle action
/// }
/// ```
public struct PrimaryButton: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.isEnabled) private var isEnabled
    @State private var isPressed: Bool = false

    let title: String
    let isLoading: Bool
    let action: () -> Void

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        _ title: String,
        isLoading: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isLoading = isLoading
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: DesignSystem.Spacing.sm) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.8)
                }
                Text(title)
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.lg)
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .background(isEnabled ? colors.primary : colors.primary.opacity(DesignSystem.Opacity.disabled))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
            .shadowStyle(DesignSystem.Shadow.sm)
        }
        .disabled(isLoading)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(DesignSystem.Animation.spring, value: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if !isPressed {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    isPressed = false
                }
        )
    }
}
