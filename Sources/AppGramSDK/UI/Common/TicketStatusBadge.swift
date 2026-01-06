import SwiftUI

/// Ticket status badge with shadcn-inspired minimal styling.
///
/// ## Example
/// ```swift
/// TicketStatusBadge(status: .inProgress)
/// ```
public struct TicketStatusBadge: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let status: TicketStatus

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private var statusColor: Color {
        switch status {
        case .new:
            return Color(hex: "#3b82f6")
        case .open:
            return Color(hex: "#f59e0b")
        case .inProgress:
            return Color(hex: "#8b5cf6")
        case .waitingOnCustomer:
            return Color(hex: "#06b6d4")
        case .resolved:
            return colors.success
        case .closed:
            return Color(hex: "#9ca3af")
        }
    }

    public init(status: TicketStatus) {
        self.status = status
    }

    public var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: status.systemImageName)
                .font(.system(size: DesignSystem.Typography.xs - 2))
            Text(status.displayName)
                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.medium))
        }
        .foregroundColor(statusColor)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(statusColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs)
                .strokeBorder(statusColor.opacity(0.2), lineWidth: DesignSystem.BorderWidth.hairline)
        )
    }
}
