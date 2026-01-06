import SwiftUI
import MarkdownUI

struct StatusUpdateCard: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let update: StatusUpdate
    let configuration: StatusConfiguration
    let isFirst: Bool

    @State private var isExpanded: Bool

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    init(update: StatusUpdate, configuration: StatusConfiguration, isFirst: Bool = false) {
        self.update = update
        self.configuration = configuration
        self.isFirst = isFirst
        _isExpanded = State(initialValue: isFirst)
    }

    private var timeAgo: String {
        if let startedAt = update.startedAt {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return formatter.localizedString(for: startedAt, relativeTo: Date())
        }
        return ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Clickable Header
            Button(action: {
                withAnimation(DesignSystem.Animation.springSmooth) {
                    isExpanded.toggle()
                }
            }) {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    // Top Row: Badge and Time
                    HStack(alignment: .center, spacing: DesignSystem.Spacing.md) {
                        StatusTypeBadge(statusType: update.statusType)

                        if !timeAgo.isEmpty {
                            HStack(spacing: DesignSystem.Spacing.xs) {
                                Image(systemName: "clock")
                                    .font(.system(size: DesignSystem.Typography.xs))
                                Text(timeAgo)
                                    .font(.system(size: DesignSystem.Typography.sm))
                            }
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                        }

                        Spacer()

                        // Expand/Collapse Icon
                        Image(systemName: "chevron.right")
                            .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }

                    // Title (Full Width)
                    Text(update.title)
                        .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                        .foregroundColor(colors.text)
                        .lineLimit(isExpanded ? nil : 2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(DesignSystem.Spacing.lg)
                .contentShape(Rectangle())
            }
            .buttonStyle(PlainButtonStyle())

            // Expandable Content
            if isExpanded {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
                    Divider()
                        .padding(.horizontal, DesignSystem.Spacing.lg)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md + 2) {
                        // Description with Markdown
                        if let description = update.description, !description.isEmpty {
                            Markdown(description)
                                .markdownTextStyle(\.text) {
                                    ForegroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                                    FontSize(DesignSystem.Typography.sm)
                                }
                                .markdownTextStyle(\.code) {
                                    FontFamilyVariant(.monospaced)
                                    BackgroundColor(colors.border.opacity(0.5))
                                }
                        }

                        // Affected Services
                        if !update.affectedServices.isEmpty {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: DesignSystem.Typography.xs))
                                        .foregroundColor(update.statusType.color)

                                    Text("Affected Services")
                                        .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                                }

                                FlowLayout(spacing: DesignSystem.Spacing.xs) {
                                    ForEach(update.affectedServices, id: \.self) { service in
                                        Text(service)
                                            .font(.system(size: DesignSystem.Typography.xs, weight: .medium))
                                            .padding(.horizontal, DesignSystem.Spacing.sm + 2)
                                            .padding(.vertical, DesignSystem.Spacing.xs)
                                            .background(update.statusType.color.opacity(0.15))
                                            .foregroundColor(update.statusType.color)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }

                        // Resolved Indicator
                        if update.state == .resolved, let resolvedAt = update.resolvedAt {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: DesignSystem.Typography.sm))
                                    .foregroundColor(colors.success)

                                Text("Resolved")
                                    .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                                    .foregroundColor(colors.success)

                                Text("•")
                                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

                                Text(resolvedAt, style: .relative)
                                    .font(.system(size: DesignSystem.Typography.sm))
                                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.lg)
                    .padding(.bottom, DesignSystem.Spacing.lg)
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .fill(colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                .strokeBorder(isExpanded ? update.statusType.color.opacity(0.2) : Color.clear, lineWidth: DesignSystem.BorderWidth.thin + 0.5)
        )
        .layeredShadow()
    }
}

// Helper view for flow layout of affected services
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return CGSize(width: proposal.replacingUnspecifiedDimensions().width, height: result.height)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var frames: [CGRect] = []
        var height: CGFloat = 0

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            height = currentY + lineHeight
        }
    }
}
