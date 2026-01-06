import SwiftUI

public struct SupportTicketCard: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let ticket: SupportTicket

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(ticket: SupportTicket) {
        self.ticket = ticket
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Text(ticket.subject)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.cardText)
                    .lineLimit(2)

                Spacer()

                TicketStatusBadge(status: ticket.status)
            }

            Text(ticket.description)
                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.muted))
                .lineLimit(2)

            HStack {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    Image(systemName: "envelope")
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    Text(ticket.userEmail)
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                }
                .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.subtle))

                Spacer()

                Text(formattedDate)
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.cardText.opacity(DesignSystem.Opacity.subtle))
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .strokeBorder(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .layeredShadow()
    }

    private var formattedDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: ticket.createdAt, relativeTo: Date())
    }
}
