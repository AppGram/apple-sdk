import SwiftUI

public struct SupportMessageView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let message: SupportMessage

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(message: SupportMessage) {
        self.message = message
    }

    public var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.lg) {
            if message.isFromSupport {
                Spacer(minLength: 40)
            }

            VStack(alignment: message.isFromSupport ? .trailing : .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.xs) {
                    if message.isFromSupport {
                        Spacer()
                    }

                    Text(message.authorName ?? "Support")
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.medium))
                        .foregroundColor(colors.text)

                    if message.isFromSupport {
                        Text("Support")
                            .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.cardBackground)
                            .padding(.horizontal, DesignSystem.Spacing.xs)
                            .padding(.vertical, DesignSystem.Spacing.xs)
                            .background(colors.primary)
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
                    } else {
                        Text("You")
                            .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.neutral600)
                            .padding(.horizontal, DesignSystem.Spacing.xs)
                            .padding(.vertical, DesignSystem.Spacing.xs)
                            .background(colors.neutral200.opacity(0.6))
                            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xs))
                    }

                    if !message.isFromSupport {
                        Spacer()
                    }
                }

                Text(message.content)
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                    .foregroundColor(message.isFromSupport ? colors.cardBackground : colors.text)
                    .padding(DesignSystem.Spacing.lg)
                    .background(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .fill(message.isFromSupport ? colors.primary : colors.cardBackground)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .strokeBorder(
                                message.isFromSupport ? Color.clear : colors.border,
                                lineWidth: DesignSystem.BorderWidth.thin
                            )
                    )
                    .layeredShadow()

                if let attachments = message.attachments, !attachments.isEmpty {
                    HStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(attachments) { attachment in
                            AttachmentBadge(attachment: attachment)
                        }
                    }
                }

                Text(formattedDate)
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
            }

            if !message.isFromSupport {
                Spacer(minLength: 40)
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: message.createdAt)
    }
}

struct AttachmentBadge: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let attachment: Attachment

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.xs) {
            Image(systemName: "paperclip")
                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
            Text(attachment.fileName)
                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                .lineLimit(1)
        }
        .foregroundColor(colors.primary)
        .padding(.horizontal, DesignSystem.Spacing.sm)
        .padding(.vertical, DesignSystem.Spacing.xs)
        .background(colors.primary.opacity(DesignSystem.Opacity.muted))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm))
    }
}
