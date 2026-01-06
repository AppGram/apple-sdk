import SwiftUI

/// A customizable widget view that can be embedded in any screen.
///
/// ## Discussion
/// WidgetView provides a flexible, fully customizable widget that can display
/// different types of content (feedback, roadmap, status, or custom) with
/// extensive customization options including styles, sizes, colors, and CTA buttons.
///
/// ## Example
/// ```swift
/// let config = WidgetConfiguration.feedback(
///     style: .card,
///     size: .medium,
///     ctaButton: CTAStyle(title: "Submit Feedback"),
///     ctaAction: {
///         // Handle CTA tap
///     }
/// )
///
/// WidgetView(configuration: config, widgetService: service)
/// ```
public struct WidgetView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @StateObject private var viewModel: WidgetViewModel
    
    private let configuration: AGWidgetConfiguration
    private let widgetService: WidgetServiceProtocol
    
    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }
    
    public init(
        configuration: AGWidgetConfiguration,
        widgetService: WidgetServiceProtocol
    ) {
        self.configuration = configuration
        self.widgetService = widgetService
        _viewModel = StateObject(wrappedValue: WidgetViewModel(
            widgetService: widgetService,
            configuration: configuration
        ))
    }
    
    public var body: some View {
        widgetContainer
            .task {
                await viewModel.loadWidgetData()
            }
    }
    
    @ViewBuilder
    private var widgetContainer: some View {
        Group {
            switch configuration.style {
            case .card:
                cardStyleWidget
            case .minimal:
                minimalStyleWidget
            case .compact:
                compactStyleWidget
            case .banner:
                bannerStyleWidget
            }
        }
        .frame(
            width: resolvedWidth,
            height: resolvedHeight
        )
    }
    
    // MARK: - Style Variants
    
    @ViewBuilder
    private var cardStyleWidget: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            headerSection
            contentSection
            if let ctaButton = configuration.ctaButton {
                ctaSection(ctaButton: ctaButton)
            }
        }
        .padding(configuration.padding)
        .background(
            configuration.backgroundColor ?? colors.cardBackground
        )
        .overlay(
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .strokeBorder(
                    configuration.borderColor ?? colors.neutral200,
                    lineWidth: DesignSystem.BorderWidth.thin
                )
        )
        .cornerRadius(configuration.cornerRadius)
        .layeredShadow()
    }
    
    @ViewBuilder
    private var minimalStyleWidget: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            headerSection
            contentSection
            if let ctaButton = configuration.ctaButton {
                ctaSection(ctaButton: ctaButton)
            }
        }
        .padding(configuration.padding)
        .background(
            configuration.backgroundColor ?? Color.clear
        )
        .overlay(
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .strokeBorder(
                    configuration.borderColor ?? colors.neutral200,
                    lineWidth: DesignSystem.BorderWidth.thin
                )
        )
        .cornerRadius(configuration.cornerRadius)
    }
    
    @ViewBuilder
    private var compactStyleWidget: some View {
        let bgColor = configuration.backgroundColor ?? colors.cardBackground
        let borderColor = configuration.borderColor ?? colors.neutral200

        HStack(spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                if let title = configuration.title {
                    Text(title)
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.text)
                }
                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                }
            }
            Spacer()
            if let ctaButton = configuration.ctaButton {
                ctaButtonView(ctaButton: ctaButton, compact: true)
            }
        }
        .padding(configuration.padding)
        .background(bgColor)
        .overlay(
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .strokeBorder(borderColor, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .cornerRadius(configuration.cornerRadius)
    }
    
    @ViewBuilder
    private var bannerStyleWidget: some View {
        let bgColor = configuration.backgroundColor ?? colors.cardBackground
        let borderColor = configuration.borderColor ?? colors.neutral200

        HStack(spacing: DesignSystem.Spacing.lg) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                if let title = configuration.title {
                    Text(title)
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.text)
                }
                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                }
            }
            Spacer()
            if let ctaButton = configuration.ctaButton {
                ctaButtonView(ctaButton: ctaButton)
            }
        }
        .padding(configuration.padding)
        .background(bgColor)
        .overlay(
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .strokeBorder(borderColor, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .cornerRadius(configuration.cornerRadius)
    }
    
    // MARK: - Sections
    
    @ViewBuilder
    private var headerSection: some View {
        if configuration.title != nil || configuration.subtitle != nil {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                if let title = configuration.title {
                    Text(title)
                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.text)
                }
                if let subtitle = configuration.subtitle {
                    Text(subtitle)
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
                }
            }
        }
    }
    
    @ViewBuilder
    private var contentSection: some View {
        if viewModel.isLoading {
            ProgressView()
                .frame(maxWidth: .infinity)
                .padding(.vertical, DesignSystem.Spacing.sm)
        } else if let error = viewModel.error {
            VStack(spacing: DesignSystem.Spacing.sm) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundColor(colors.error)
                Text("Failed to load widget")
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DesignSystem.Spacing.sm)
        } else {
            widgetContent
        }
    }
    
    @ViewBuilder
    private var widgetContent: some View {
        switch configuration.type {
        case .feedback:
            feedbackWidgetContent
        case .roadmap:
            roadmapWidgetContent
        case .status:
            statusWidgetContent
        case .custom:
            if let customContent = configuration.customContent {
                customContent()
            } else {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder
    private var feedbackWidgetContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(colors.primary)
                Text("Share your ideas and help us improve")
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }
        }
    }
    
    @ViewBuilder
    private var roadmapWidgetContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "map.fill")
                    .foregroundColor(colors.primary)
                Text("See what's coming next in our roadmap")
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }
        }
    }
    
    @ViewBuilder
    private var statusWidgetContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(colors.success)
                Text("All systems operational")
                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }
        }
    }
    
    @ViewBuilder
    private func ctaSection(ctaButton: AGWidgetConfiguration.CTAStyle) -> some View {
        ctaButtonView(ctaButton: ctaButton)
    }
    
    @ViewBuilder
    private func ctaButtonView(ctaButton: AGWidgetConfiguration.CTAStyle, compact: Bool = false) -> some View {
        Button(action: {
            configuration.ctaAction?()
        }) {
            Text(ctaButton.title)
                .font(.system(size: compact ? 14 : 16, weight: ctaButton.fontWeight))
                .foregroundColor(ctaButton.foregroundColor)
                .padding(ctaButton.padding)
                .frame(maxWidth: compact ? nil : .infinity)
                .background(ctaButton.backgroundColor)
                .cornerRadius(ctaButton.cornerRadius)
        }
    }
    
    // MARK: - Helpers
    
    private var resolvedWidth: CGFloat? {
        switch configuration.size {
        case .small:
            return 280
        case .medium:
            return 350
        case .large:
            return nil // Full width
        case .custom(let size):
            return size.width > 0 ? size.width : nil
        }
    }
    
    private var resolvedHeight: CGFloat? {
        switch configuration.size {
        case .small:
            return 150
        case .medium:
            return 200
        case .large:
            return 250
        case .custom(let size):
            return size.height > 0 ? size.height : nil
        }
    }
}
