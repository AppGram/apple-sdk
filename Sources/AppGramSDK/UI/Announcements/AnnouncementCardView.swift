import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

/// A card view displaying a single announcement with its features.
///
/// ## Discussion
/// This view follows mode announcement style with a dark overlay,
/// media preview, and clean typography. It displays a preview image from the announcement's
/// imageUrl, title, description, privacy notice (if any), and action buttons.
struct AnnouncementCardView: View {
    let announcement: Announcement
    let configuration: AnnouncementCardConfiguration
    let onTryIt: (() -> Void)?
    let onNotNow: (() -> Void)?

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private var accent: Color {
        configuration.titleColor ?? colors.primary
    }

    private var isCardStyle: Bool {
        configuration.presentationStyle == .card
    }

    private var sheetForeground: Color {
        Color.white
    }

    private var sheetSecondary: Color {
        colors.neutral400
    }

    init(
        announcement: Announcement,
        configuration: AnnouncementCardConfiguration = .default,
        onTryIt: (() -> Void)? = nil,
        onNotNow: (() -> Void)? = nil
    ) {
        self.announcement = announcement
        self.configuration = configuration
        self.onTryIt = onTryIt
        self.onNotNow = onNotNow
    }

    var body: some View {
        Group {
            if isCardStyle {
                cardContent
            } else {
                sheetContent
            }
        }
    }

    private var cardContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            headerMedia

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                metaRow

                Text(announcement.title)
                    .font(.system(size: configuration.titleFontSize, weight: DesignSystem.Typography.semibold, design: .rounded))
                    .foregroundColor(configuration.titleColor ?? colors.text)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = announcement.subtitle {
                    Text(subtitle)
                        .font(.system(size: configuration.descriptionFontSize))
                        .foregroundColor(configuration.descriptionColor ?? colors.text.opacity(DesignSystem.Opacity.subtle))
                        .lineSpacing(DesignSystem.Spacing.xs)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)

            if !announcement.features.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Highlights")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))

                    VStack(spacing: DesignSystem.Spacing.sm) {
                        ForEach(announcement.features) { feature in
                            AnnouncementFeatureRow(feature: feature)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }

            if let privacyNote = announcement.privacyNote {
                HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.neutral500)

                    Text(privacyNote)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.neutral500)

                    if let learnMoreUrl = announcement.learnMoreUrl {
                        Button(action: {
                            if let url = URL(string: learnMoreUrl) {
                                #if canImport(UIKit)
                                UIApplication.shared.open(url)
                                #endif
                            }
                        }) {
                            Text("Learn more")
                                .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                                .foregroundColor(colors.primary)
                        }
                    }
                }
                .padding(DesignSystem.Spacing.md)
                .background(colors.background.opacity(0.6))
                .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous))
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }

            if configuration.primaryButton != nil || configuration.secondaryButton != nil {
                VStack(spacing: DesignSystem.Spacing.md) {
                    if let primaryButton = configuration.primaryButton {
                        ConfigurableButton(configuration: primaryButton, action: onTryIt ?? primaryButton.action)
                    }

                    if let secondaryButton = configuration.secondaryButton {
                        ConfigurableButton(configuration: secondaryButton, action: onNotNow ?? secondaryButton.action)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
        }
        .padding(.top, DesignSystem.Spacing.xl)
        .padding(.bottom, DesignSystem.Spacing.xl)
        .background(configuration.backgroundColor ?? colors.cardBackground)
        .cornerRadius(configuration.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .strokeBorder(colors.border.opacity(0.6), lineWidth: DesignSystem.BorderWidth.thin)
        )
        .shadow(color: colors.text.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private var sheetContent: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            if announcement.imageUrl != nil {
                sheetHero
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(announcement.title)
                    .font(.system(size: 34, weight: DesignSystem.Typography.bold, design: .rounded))
                    .foregroundColor(configuration.titleColor ?? sheetForeground)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = announcement.subtitle {
                    Text(subtitle)
                        .font(.system(size: configuration.descriptionFontSize))
                        .foregroundColor(configuration.descriptionColor ?? sheetForeground.opacity(0.7))
                        .lineSpacing(DesignSystem.Spacing.xs)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)
            .padding(.top, DesignSystem.Spacing.sm)

            if !announcement.features.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    Text("Highlights")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(sheetSecondary)

                    VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                        ForEach(announcement.features) { feature in
                            HStack(alignment: .top, spacing: DesignSystem.Spacing.sm) {
                                ZStack {
                                    Circle()
                                        .fill(colors.primary)
                                        .frame(width: 18, height: 18)
                                    Image(systemName: "checkmark")
                                        .font(.system(size: DesignSystem.Typography.xs, weight: .bold))
                                        .foregroundColor(colors.neutral900)
                                }
                                .padding(.top, 2)

                                VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                                    Text(feature.title)
                                        .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                                        .foregroundColor(sheetForeground)

                                    if let description = feature.description {
                                        Text(description)
                                            .font(.system(size: DesignSystem.Typography.sm))
                                            .foregroundColor(sheetForeground.opacity(0.75))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }

            if let privacyNote = announcement.privacyNote {
                sheetAttentionNote(privacyNote)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
            }

            if configuration.primaryButton != nil || configuration.secondaryButton != nil {
                VStack(spacing: DesignSystem.Spacing.md) {
                    if let primaryButton = configuration.primaryButton {
                        SheetActionButton(configuration: primaryButton, action: onTryIt ?? primaryButton.action)
                    }

                    if let secondaryButton = configuration.secondaryButton {
                        SheetActionButton(configuration: secondaryButton, action: onNotNow ?? secondaryButton.action)
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.bottom, DesignSystem.Spacing.md)
            }
        }
        .padding(.top, DesignSystem.Spacing.xl)
    }

    private var sheetHero: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.3, green: 0.5, blue: 1.0),
                            Color(red: 0.5, green: 0.3, blue: 1.0),
                            Color(red: 0.8, green: 0.2, blue: 0.8)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: 280)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: DesignSystem.BorderWidth.hairline)
                )

            sheetHeroMedia
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }

    private var sheetHeroMedia: some View {
        Group {
            if let imageUrl = announcement.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(DesignSystem.Spacing.xxl)
                            .shadow(color: Color.black.opacity(0.4), radius: 30, x: 0, y: 15)
                    case .failure:
                        sheetHeroPlaceholder
                    default:
                        ProgressView()
                            .tint(.white)
                    }
                }
            } else {
                sheetHeroPlaceholder
            }
        }
    }

    private var sheetHeroPlaceholder: some View {
        Image(systemName: "sparkles")
            .font(.system(size: 60))
            .foregroundColor(.white.opacity(0.4))
    }

    private var sheetMetaRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            Text("Team update")
                .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                .foregroundColor(sheetForeground)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs)
                .background(colors.neutral800)
                .clipShape(Capsule())

            if let version = announcement.version {
                Text(version)
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(sheetSecondary)
            }

            Spacer()

            Text(announcement.createdAt, style: .date)
                .font(.system(size: DesignSystem.Typography.xs))
                .foregroundColor(sheetSecondary)
        }
        .padding(.horizontal, DesignSystem.Spacing.xl)
    }

    private func sheetAttentionNote(_ note: String) -> some View {
        let text = Text(note)
            .font(.system(size: DesignSystem.Typography.sm))
            .foregroundColor(sheetSecondary)

        return VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
            if let learnMoreUrl = announcement.learnMoreUrl,
               let url = URL(string: learnMoreUrl) {
                Button(action: {
                    #if canImport(UIKit)
                    UIApplication.shared.open(url)
                    #endif
                }) {
                    (text + Text(" ") + Text("Learn more").underline())
                        .foregroundColor(sheetSecondary)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            } else {
                text
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private var metaRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if let version = announcement.version {
                Text(version)
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(accent)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs + 1)
                    .background(accent.opacity(0.14))
                    .clipShape(Capsule())
            }

            Text(announcement.createdAt, style: .date)
                .font(.system(size: DesignSystem.Typography.xs))
                .foregroundColor(colors.neutral500)

            Spacer()
        }
    }

    private var headerMedia: some View {
        Group {
            if let imageUrl = announcement.imageUrl {
                AnnouncementMediaView(imageUrl: imageUrl)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
            } else {
                HStack(spacing: DesignSystem.Spacing.md) {
                    ZStack {
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                            .fill(accent.opacity(0.12))
                            .frame(width: 48, height: 48)
                        Image(systemName: "sparkles")
                            .font(.system(size: DesignSystem.Typography.base, weight: .semibold))
                            .foregroundColor(accent)
                    }

                    Text("What's new")
                        .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                        .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }
        }
    }
}

/// A button view that uses ButtonConfiguration for styling.
private struct ConfigurableButton: View {
    let configuration: ButtonConfiguration
    let action: (() -> Void)?

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            Text(configuration.title)
                .font(.system(size: configuration.fontSize, weight: configuration.fontWeight))
                .foregroundColor(resolvedForegroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: resolvedHeight)
                .padding(configuration.padding)
                .background(resolvedBackgroundColor)
                .cornerRadius(resolvedCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: resolvedCornerRadius)
                        .strokeBorder(resolvedBorderColor, lineWidth: resolvedBorderWidth)
                )
        }
    }

    private var resolvedBackgroundColor: Color? {
        switch configuration.style {
        case .primary:
            return configuration.backgroundColor ?? colors.primary
        case .secondary:
            return colors.cardBackground.opacity(0.7)
        case .text:
            return nil
        case .custom:
            return configuration.backgroundColor
        }
    }

    private var resolvedForegroundColor: Color {
        switch configuration.style {
        case .primary:
            return configuration.foregroundColor ?? .white
        case .secondary, .text:
            return configuration.foregroundColor ?? colors.text
        case .custom:
            return configuration.foregroundColor ?? colors.text
        }
    }

    private var resolvedBorderColor: Color {
        switch configuration.style {
        case .secondary, .text, .primary:
            return .clear
        case .custom:
            return configuration.foregroundColor?.opacity(0.3) ?? colors.border
        }
    }

    private var resolvedBorderWidth: CGFloat {
        configuration.style == .custom ? DesignSystem.BorderWidth.thin : 0
    }

    private var resolvedHeight: CGFloat? {
        configuration.height
    }

    private var resolvedCornerRadius: CGFloat {
        configuration.cornerRadius
    }
}

/// A view displaying media (image or video) for the announcement.
private struct AnnouncementMediaView: View {
    let imageUrl: String

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private let fixedHeight: CGFloat = 160

    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(colors.border.opacity(0.2))
                        .frame(height: fixedHeight)

                    ProgressView()
                        .tint(colors.primary)
                }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: fixedHeight)
                    .clipped()
                    .cornerRadius(DesignSystem.CornerRadius.lg)
                    .overlay(
                        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                            .strokeBorder(colors.border.opacity(0.4), lineWidth: DesignSystem.BorderWidth.hairline)
                    )
            case .failure:
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(colors.border.opacity(0.2))
                        .frame(height: fixedHeight)

                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "photo")
                            .font(.system(size: DesignSystem.Typography.xxxl))
                            .foregroundColor(colors.neutral500)
                        Text("Image unavailable")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                            .foregroundColor(colors.neutral500)
                    }
                }
            @unknown default:
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(colors.border.opacity(0.3))
                        .frame(height: fixedHeight)

                    ProgressView()
                        .tint(colors.primary)
                }
            }
        }
        .frame(height: fixedHeight)
    }
}

extension View {
    #if canImport(UIKit)
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    #else
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        self.cornerRadius(radius)
    }
    #endif
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    #if canImport(UIKit)
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
    #else
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.addRoundedRect(in: rect, cornerSize: CGSize(width: radius, height: radius))
        return path
    }
    #endif
}

private struct SheetActionButton: View {
    let configuration: ButtonConfiguration
    let action: (() -> Void)?

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        Button(action: {
            action?()
        }) {
            Text(configuration.title)
                .font(.system(size: configuration.fontSize, weight: configuration.fontWeight))
                .foregroundColor(resolvedForegroundColor)
                .frame(maxWidth: .infinity)
                .frame(height: resolvedHeight)
                .padding(configuration.padding)
                .background(resolvedBackgroundColor)
                .cornerRadius(resolvedCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: resolvedCornerRadius)
                        .strokeBorder(resolvedBorderColor, lineWidth: resolvedBorderWidth)
                )
        }
    }

    private var resolvedBackgroundColor: Color? {
        switch configuration.style {
        case .primary:
            return configuration.backgroundColor ?? Color.white
        case .secondary, .text:
            return configuration.backgroundColor ?? Color.clear
        case .custom:
            return configuration.backgroundColor
        }
    }

    private var resolvedForegroundColor: Color {
        switch configuration.style {
        case .primary:
            return configuration.foregroundColor ?? colors.neutral900
        case .secondary, .text:
            return configuration.foregroundColor ?? Color.white
        case .custom:
            return configuration.foregroundColor ?? Color.white
        }
    }

    private var resolvedBorderColor: Color {
        .clear
    }

    private var resolvedBorderWidth: CGFloat {
        0
    }

    private var resolvedHeight: CGFloat? {
        configuration.style == .primary ? 56 : 44
    }

    private var resolvedCornerRadius: CGFloat {
        configuration.style == .primary ? 28 : 12
    }
}

/// A row displaying a single feature in the announcement.
private struct AnnouncementFeatureRow: View {
    let feature: AnnouncementFeature

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    var body: some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            if let imageUrl = feature.imageUrl {
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 36, height: 36)
                            .cornerRadius(DesignSystem.CornerRadius.sm)
                    default:
                        featureIconPlaceholder
                    }
                }
            } else {
                featureIconPlaceholder
            }

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(feature.title)
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                if let description = feature.description {
                    Text(description)
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.neutral500)
                        .lineSpacing(DesignSystem.Spacing.xs)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, DesignSystem.Spacing.xs)
    }

    private var featureIconPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(colors.primary.opacity(0.12))
                .frame(width: 36, height: 36)

            Image(systemName: "sparkles")
                .font(.system(size: DesignSystem.Typography.base))
                .foregroundColor(colors.primary)
        }
    }
}

#if DEBUG
struct AnnouncementCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    AnnouncementCardView(
                        announcement: Announcement(
                            id: "1",
                            title: "Introducing agent mode",
                            subtitle: "ChatGPT can now do work on its own computer, from research and spreadsheets to booking reservations and more.",
                            features: [],
                            version: "2.0.0",
                            imageUrl: "https://images.unsplash.com/photo-1677442136019-21780ecad995?w=800&q=80",
                            privacyNote: "Agent mode uses a remote browser and takes screenshots. You can take control at any time.",
                            learnMoreUrl: "https://openai.com/blog/introducing-agent-mode",
                            createdAt: Date()
                        ),
                        configuration: .init(
                            primaryButton: .primary(title: "Try it"),
                            secondaryButton: .text(title: "Not now"),
                            presentationStyle: .sheet
                        ),
                        onTryIt: {
                            print("Try it tapped")
                        },
                        onNotNow: {
                            print("Not now tapped")
                        }
                    )
                    .padding()
                }
            }
        }
        .previewDisplayName("Announcement Sheet Style")
    }
}
#endif
