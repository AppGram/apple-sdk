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
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            timelineMarker

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                Button(action: {
                    withAnimation(DesignSystem.Animation.springSmooth) {
                        isExpanded.toggle()
                    }
                }) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        HStack(spacing: DesignSystem.Spacing.sm) {
                            StatusTypeBadge(statusType: update.statusType)

                            if !timeAgo.isEmpty {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "clock")
                                        .font(.system(size: DesignSystem.Typography.xs))
                                    Text(timeAgo)
                                        .font(.system(size: DesignSystem.Typography.xs))
                                }
                                .foregroundColor(colors.neutral500)
                            }

                            Spacer()

                            Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: DesignSystem.Typography.xs, weight: .semibold))
                                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                        }

                        Text(update.title)
                            .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                            .foregroundColor(colors.text)
                            .lineLimit(isExpanded ? nil : 2)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .buttonStyle(PlainButtonStyle())

                if isExpanded {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.md + 2) {
                        if let description = update.description, !description.isEmpty {
                            Markdown(description)
                                .markdownTextStyle(\.text) {
                                    ForegroundColor(colors.neutral500)
                                    FontSize(DesignSystem.Typography.sm)
                                }
                                .markdownTextStyle(\.code) {
                                    FontFamilyVariant(.monospaced)
                                    BackgroundColor(colors.border.opacity(0.5))
                                }
                        }

                        if let affectedServices = update.affectedServices, !affectedServices.isEmpty {
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                                HStack(spacing: DesignSystem.Spacing.xs) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: DesignSystem.Typography.xs))
                                        .foregroundColor(update.statusType.color)

                                    Text("Affected Services")
                                        .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                                        .foregroundColor(colors.neutral500)
                                }

                                FlowLayout(spacing: DesignSystem.Spacing.xs) {
                                    ForEach(affectedServices, id: \.self) { service in
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

                        if update.state == .resolved, let resolvedAt = update.resolvedAt {
                            HStack(spacing: DesignSystem.Spacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: DesignSystem.Typography.sm))
                                    .foregroundColor(colors.success)

                                Text("Resolved")
                                    .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                                    .foregroundColor(colors.success)

                                Text("•")
                                    .foregroundColor(colors.neutral500)

                                Text(resolvedAt, style: .relative)
                                    .font(.system(size: DesignSystem.Typography.sm))
                                    .foregroundColor(colors.neutral500)
                            }
                        }
                    }
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(DesignSystem.Spacing.lg)
            .background(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                    .fill(colors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg, style: .continuous)
                    .strokeBorder(isExpanded ? update.statusType.color.opacity(0.2) : colors.border, lineWidth: DesignSystem.BorderWidth.thin)
            )
            .layeredShadow()
        }
    }

    private var timelineMarker: some View {
        VStack(spacing: 0) {
            Circle()
                .fill(update.statusType.color)
                .frame(width: 10, height: 10)

            Rectangle()
                .fill(colors.border)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
                .opacity(0.6)
        }
        .padding(.top, DesignSystem.Spacing.lg)
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
