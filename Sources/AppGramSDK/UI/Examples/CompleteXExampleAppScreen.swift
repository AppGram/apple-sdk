import SwiftUI

public struct CompleteXExampleAppScreen: View {
    public struct Configuration: Sendable {
        public var surveySlug: String
        public var supportFormId: String
        public var contactFormId: String
        public var statusSlug: String
        public var releasesOrgSlug: String
        public var releasesProjectSlug: String
        public var widgetStyle: AGWidgetConfiguration.WidgetStyle
        public var widgetSize: AGWidgetConfiguration.WidgetSize

        public init(
            surveySlug: String = "user-satisfaction",
            supportFormId: String = "support",
            contactFormId: String = "contact-us",
            statusSlug: String = "status",
            releasesOrgSlug: String = "your-org",
            releasesProjectSlug: String = "your-project",
            widgetStyle: AGWidgetConfiguration.WidgetStyle = .card,
            widgetSize: AGWidgetConfiguration.WidgetSize = .medium
        ) {
            self.surveySlug = surveySlug
            self.supportFormId = supportFormId
            self.contactFormId = contactFormId
            self.statusSlug = statusSlug
            self.releasesOrgSlug = releasesOrgSlug
            self.releasesProjectSlug = releasesProjectSlug
            self.widgetStyle = widgetStyle
            self.widgetSize = widgetSize
        }
    }

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @State private var hasAppeared = false
    @State private var alertState: AlertState?

    private let configuration: Configuration

    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                        heroSection
                        setupStatusCard

                        ForEach(featureSections) { section in
                            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                                SectionHeader(title: section.title, subtitle: section.subtitle)

                                VStack(spacing: DesignSystem.Spacing.md) {
                                    ForEach(Array(section.features.enumerated()), id: \.element.id) { index, feature in
                                        featureRow(for: feature)
                                            .opacity(hasAppeared ? 1 : 0)
                                            .offset(y: hasAppeared ? 0 : 12)
                                            .animation(
                                                DesignSystem.Animation.springSmooth.delay(Double(index) * 0.04),
                                                value: hasAppeared
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .padding(DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.xxxl)
                }
            }
            .navigationTitle("CompleteX")
            .navigationBarTitleDisplayMode(.large)
        }
        .onAppear {
            guard !hasAppeared else { return }
            withAnimation(DesignSystem.Animation.springSmooth) {
                hasAppeared = true
            }
        }
        .alert(item: $alertState) { state in
            Alert(
                title: Text(state.title),
                message: Text(state.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private var isConfigured: Bool {
        AppGramSDK.shared.configuration != nil
    }

    private var backgroundView: some View {
        ZStack {
            LinearGradient(
                colors: [colors.neutral50, colors.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            Circle()
                .fill(colors.primary.opacity(0.14))
                .frame(width: 260, height: 260)
                .blur(radius: 30)
                .offset(x: -140, y: -180)

            RoundedRectangle(cornerRadius: 180)
                .fill(colors.accent.opacity(0.08))
                .frame(width: 320, height: 220)
                .rotationEffect(.degrees(18))
                .blur(radius: 10)
                .offset(x: 160, y: -120)

            Circle()
                .fill(colors.secondary.opacity(0.12))
                .frame(width: 200, height: 200)
                .blur(radius: 22)
                .offset(x: 140, y: 220)
        }
    }

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            Text("CompleteX Example App")
                .font(.system(size: DesignSystem.Typography.xxxl, weight: DesignSystem.Typography.bold, design: .rounded))
                .foregroundColor(colors.text)

            Text("A modern, end-to-end showcase of every AppGram feature, ready to drop into your iOS app.")
                .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.medium))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: DesignSystem.Spacing.sm) {
                FeatureTag(title: "Feedback", tint: colors.primary)
                FeatureTag(title: "Support", tint: colors.secondary)
                FeatureTag(title: "Status", tint: colors.accent)
            }
        }
        .padding(DesignSystem.Spacing.xl)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .fill(
                    LinearGradient(
                        colors: [colors.cardBackground, colors.neutral50],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .stroke(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .shadowStyle(DesignSystem.Shadow.sm)
    }

    private var setupStatusCard: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            ZStack {
                Circle()
                    .fill((isConfigured ? colors.success : colors.warning).opacity(0.18))
                    .frame(width: 44, height: 44)
                Image(systemName: isConfigured ? "checkmark.seal.fill" : "bolt.trianglebadge.exclamationmark.fill")
                    .font(.system(size: 20))
                    .foregroundColor(isConfigured ? colors.success : colors.warning)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(isConfigured ? "SDK Configured" : "Connect to AppGram")
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                Text(isConfigured ? "Live data is enabled for every feature." : "Set your project ID to unlock live previews.")
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }

            Spacer()
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .fill(colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                .stroke(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .shadowStyle(DesignSystem.Shadow.xs)
    }

    private var featureSections: [FeatureSection] {
        [
            FeatureSection(
                title: "Listen & Learn",
                subtitle: "Capture insights and shape the roadmap with customers.",
                features: [
                    FeatureItem(
                        title: "Feedback Hub",
                        subtitle: "Collect and prioritize feature requests.",
                        icon: "bubble.left.and.bubble.right.fill",
                        tint: colors.primary,
                        badge: "Core",
                        kind: .navigation {
                            try AnyView(AppGramSDK.shared.feedbackView())
                        }
                    ),
                    FeatureItem(
                        title: "Product Roadmap",
                        subtitle: "Show what is shipping now, next, and later.",
                        icon: "point.3.connected.trianglepath.dotted",
                        tint: colors.accent,
                        badge: "Core",
                        kind: .navigation {
                            try AnyView(AppGramSDK.shared.roadmapView())
                        }
                    ),
                    FeatureItem(
                        title: "Surveys",
                        subtitle: "Launch structured surveys and capture sentiment.",
                        icon: "list.bullet.rectangle.portrait.fill",
                        tint: colors.secondary,
                        badge: "Research",
                        kind: .navigation {
                            try AnyView(AppGramSDK.shared.surveyView(slug: configuration.surveySlug))
                        }
                    )
                ]
            ),
            FeatureSection(
                title: "Support & Success",
                subtitle: "Help customers faster with self-serve and human support.",
                features: [
                    FeatureItem(
                        title: "Support Inbox",
                        subtitle: "Track tickets and conversations in one place.",
                        icon: "tray.full.fill",
                        tint: colors.success,
                        badge: "Core",
                        kind: .navigation {
                            try AnyView(AppGramSDK.shared.supportView())
                        }
                    ),
                    FeatureItem(
                        title: "Support Forms",
                        subtitle: "Route requests with dedicated forms.",
                        icon: "doc.text.fill",
                        tint: colors.primary,
                        badge: "Forms",
                        kind: .navigation {
                            try AnyView(AppGramSDK.shared.supportFormView(formId: configuration.supportFormId))
                        }
                    ),
                    FeatureItem(
                        title: "Help Center",
                        subtitle: "Surface articles, guides, and decision flows.",
                        icon: "book.closed.fill",
                        tint: colors.accent,
                        badge: "Self-serve",
                        kind: .navigation {
                            try AnyView(AppGramSDK.shared.helpCenterView())
                        }
                    ),
                    FeatureItem(
                        title: "Contact Form",
                        subtitle: "Capture leads and customer questions.",
                        icon: "envelope.open.fill",
                        tint: colors.secondary,
                        badge: "Forms",
                        kind: .navigation {
                            try AnyView(AppGramSDK.shared.contactFormView(formId: configuration.contactFormId))
                        }
                    )
                ]
            ),
            FeatureSection(
                title: "Operate & Announce",
                subtitle: "Keep customers informed with real-time updates.",
                features: [
                    FeatureItem(
                        title: "Status Page",
                        subtitle: "Report incidents and service health.",
                        icon: "waveform.path.ecg",
                        tint: colors.warning,
                        badge: "Ops",
                        kind: .navigation {
                            try AnyView(AppGramSDK.shared.statusPageView(slug: configuration.statusSlug))
                        }
                    ),
                    FeatureItem(
                        title: "Release Notes",
                        subtitle: "Share product updates and changelogs.",
                        icon: "sparkles.rectangle.stack.fill",
                        tint: colors.primary,
                        badge: "Updates",
                        kind: .navigation {
                            try AnyView(
                                AppGramSDK.shared.releasesView(
                                    orgSlug: configuration.releasesOrgSlug,
                                    projectSlug: configuration.releasesProjectSlug
                                )
                            )
                        }
                    ),
                    FeatureItem(
                        title: "Widget Gallery",
                        subtitle: "Embed contextual widgets anywhere in the app.",
                        icon: "square.grid.2x2.fill",
                        tint: colors.accent,
                        badge: "Embed",
                        kind: .navigation {
                            AnyView(WidgetShowcaseView(configuration: configuration))
                        }
                    ),
                    FeatureItem(
                        title: "Announcements",
                        subtitle: "Deliver launch updates with immersive cards.",
                        icon: "megaphone.fill",
                        tint: colors.secondary,
                        badge: "Engage",
                        kind: .action(action: {
                            Task { @MainActor in
                                await AppGramSDK.shared.showAnnouncements()
                            }
                        })
                    ),
                    FeatureItem(
                        title: "Popup Prompts",
                        subtitle: "Trigger targeted popups when it matters.",
                        icon: "rectangle.inset.badge.plus",
                        tint: colors.success,
                        badge: "Engage",
                        kind: .action(action: triggerPopup)
                    )
                ]
            )
        ]
    }

    @MainActor
    private func triggerPopup() {
        do {
            try AppGramSDK.shared.getPopupManager().showPopupManually()
        } catch {
            alertState = AlertState(
                title: "Popup Not Ready",
                message: "Configure the SDK with popup settings to preview this feature."
            )
        }
    }

    @ViewBuilder
    private func featureRow(for feature: FeatureItem) -> some View {
        switch feature.kind {
        case .navigation(let builder):
            NavigationLink {
                FeatureDestinationView(title: feature.title, builder: builder)
            } label: {
                FeatureCard(feature: feature)
            }
            .buttonStyle(.plain)
        case .action(let action):
            Button(action: action) {
                FeatureCard(feature: feature)
            }
            .buttonStyle(.plain)
        }
    }
}

private struct FeatureSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let features: [FeatureItem]
}

private struct FeatureItem: Identifiable {
    enum Kind {
        case navigation(builder: () throws -> AnyView)
        case action(action: () -> Void)
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let tint: Color
    let badge: String
    let kind: Kind
}

private struct SectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            Text(title)
                .font(.system(size: DesignSystem.Typography.xl, weight: DesignSystem.Typography.semibold))
            Text(subtitle)
                .font(.system(size: DesignSystem.Typography.sm))
                .foregroundStyle(.secondary)
        }
    }
}

private struct FeatureCard: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let feature: FeatureItem

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.lg) {
            ZStack {
                Circle()
                    .fill(feature.tint.opacity(0.16))
                    .frame(width: 50, height: 50)
                Image(systemName: feature.icon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(feature.tint)
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Text(feature.title)
                        .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.text)

                    FeatureBadge(title: feature.badge)
                }

                Text(feature.subtitle)
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }

            Spacer()

            Image(systemName: trailingIcon)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(colors.neutral400)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .fill(colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .stroke(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .shadowStyle(DesignSystem.Shadow.xs)
    }

    private var trailingIcon: String {
        switch feature.kind {
        case .navigation:
            return "chevron.right"
        case .action:
            return "sparkles"
        }
    }
}

private struct FeatureBadge: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let title: String

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        Text(title)
            .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
            .foregroundColor(colors.neutral600)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, 2)
            .background(
                Capsule().fill(colors.neutral100)
            )
    }
}

private struct FeatureTag: View {
    let title: String
    let tint: Color

    var body: some View {
        Text(title)
            .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
            .foregroundColor(tint)
            .padding(.horizontal, DesignSystem.Spacing.sm)
            .padding(.vertical, 4)
            .background(
                Capsule().fill(tint.opacity(0.12))
            )
    }
}

private struct FeatureDestinationView: View {
    let title: String
    let result: Result<AnyView, AppGramError>

    init(title: String, builder: () throws -> AnyView) {
        self.title = title
        self.result = Result { try builder() }
            .mapError { $0 as? AppGramError ?? .invalidResponse }
    }

    var body: some View {
        Group {
            switch result {
            case .success(let view):
                view
            case .failure:
                UnavailableFeatureView(title: title)
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct UnavailableFeatureView: View {
    let title: String

    var body: some View {
        EmptyStateView(
            icon: "slider.horizontal.3",
            title: "\(title) needs setup",
            message: "Configure AppGramSDK to see live data in this screen."
        )
    }
}

private struct WidgetShowcaseView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    let configuration: CompleteXExampleAppScreen.Configuration

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                Text("Widget Gallery")
                    .font(.system(size: DesignSystem.Typography.xxl, weight: DesignSystem.Typography.bold, design: .rounded))
                    .foregroundColor(colors.text)

                Text("Embed live AppGram widgets in any surface to keep users informed.")
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))

                widgetCard(
                    title: "Feedback Widget",
                    subtitle: "Quick CTA for sharing ideas.",
                    builder: {
                        try AnyView(
                            AppGramSDK.shared.feedbackWidget(
                                style: configuration.widgetStyle,
                                size: configuration.widgetSize
                            )
                        )
                    }
                )

                widgetCard(
                    title: "Roadmap Widget",
                    subtitle: "Preview the roadmap in context.",
                    builder: {
                        try AnyView(
                            AppGramSDK.shared.roadmapWidget(
                                style: configuration.widgetStyle,
                                size: configuration.widgetSize
                            )
                        )
                    }
                )

                widgetCard(
                    title: "Status Widget",
                    subtitle: "Surface live system health.",
                    builder: {
                        try AnyView(
                            AppGramSDK.shared.statusWidget(
                                style: configuration.widgetStyle,
                                size: configuration.widgetSize,
                                slug: configuration.statusSlug
                            )
                        )
                    }
                )
            }
            .padding(DesignSystem.Spacing.xl)
        }
        .background(colors.background)
        .navigationBarTitleDisplayMode(.inline)
    }

    private func widgetCard(
        title: String,
        subtitle: String,
        builder: () throws -> AnyView
    ) -> some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(title)
                    .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)
                Text(subtitle)
                    .font(.system(size: DesignSystem.Typography.sm))
                    .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            }

            if let widget = try? builder() {
                widget
            } else {
                InlineUnavailableView()
            }
        }
        .padding(DesignSystem.Spacing.lg)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .fill(colors.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .stroke(colors.neutral200, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .shadowStyle(DesignSystem.Shadow.xs)
    }
}

private struct InlineUnavailableView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        HStack(spacing: DesignSystem.Spacing.md) {
            Image(systemName: "lock.fill")
                .foregroundColor(colors.neutral500)
            Text("Configure AppGramSDK to load this widget.")
                .font(.system(size: DesignSystem.Typography.sm))
                .foregroundColor(colors.text.opacity(DesignSystem.Opacity.muted))
            Spacer()
        }
        .padding(DesignSystem.Spacing.md)
        .background(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md)
                .fill(colors.neutral100)
        )
    }
}

private struct AlertState: Identifiable {
    let id = UUID()
    let title: String
    let message: String
}
