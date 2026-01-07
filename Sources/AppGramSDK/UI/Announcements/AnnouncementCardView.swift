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
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.lg) {
            headerMedia

            VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                metaRow

                Text(announcement.title)
                    .font(.system(size: configuration.titleFontSize, weight: DesignSystem.Typography.bold, design: .rounded))
                    .foregroundColor(configuration.titleColor ?? colors.text)
                    .fixedSize(horizontal: false, vertical: true)

                if let subtitle = announcement.subtitle {
                    Text(subtitle)
                        .font(.system(size: configuration.descriptionFontSize))
                        .foregroundColor(configuration.descriptionColor ?? colors.neutral500)
                        .lineSpacing(DesignSystem.Spacing.xs)
                }
            }
            .padding(.horizontal, DesignSystem.Spacing.xl)

            if !announcement.features.isEmpty {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    Text("Highlights")
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.text)

                    VStack(spacing: DesignSystem.Spacing.md) {
                        ForEach(announcement.features) { feature in
                            AnnouncementFeatureRow(feature: feature)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
            }

            if let privacyNote = announcement.privacyNote {
                HStack(spacing: DesignSystem.Spacing.sm) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                        .foregroundColor(colors.neutral500)

                    Text(privacyNote)
                        .font(.system(size: DesignSystem.Typography.sm))
                        .foregroundColor(colors.neutral500)
                        .lineLimit(2)

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
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.sm)
                .background(colors.border.opacity(DesignSystem.Opacity.subtle))
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
                .padding(.bottom, DesignSystem.Spacing.xl)
            }
        }
        .padding(.top, announcement.imageUrl == nil ? DesignSystem.Spacing.lg : 0)
        .background(configuration.backgroundColor ?? colors.cardBackground)
        .cornerRadius(configuration.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: configuration.cornerRadius)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(accent)
                .frame(width: 4)
                .padding(.vertical, DesignSystem.Spacing.lg)
                .offset(x: 2)
        }
        .layeredShadow()
    }

    private var metaRow: some View {
        HStack(spacing: DesignSystem.Spacing.sm) {
            if let version = announcement.version {
                Text(version)
                    .font(.system(size: DesignSystem.Typography.xs, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, DesignSystem.Spacing.md)
                    .padding(.vertical, DesignSystem.Spacing.xs + 1)
                    .background(accent)
                    .clipShape(Capsule())
            }

            Text(announcement.createdAt, style: .date)
                .font(.system(size: DesignSystem.Typography.xs))
                .foregroundColor(colors.neutral500)
                .padding(.horizontal, DesignSystem.Spacing.md)
                .padding(.vertical, DesignSystem.Spacing.xs + 1)
                .background(colors.border.opacity(DesignSystem.Opacity.subtle))
                .clipShape(Capsule())

            Spacer()
        }
    }

    private var headerMedia: some View {
        Group {
            if let imageUrl = announcement.imageUrl {
                AnnouncementMediaView(imageUrl: imageUrl)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.xl)
            } else {
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                    ZStack {
                        Circle()
                            .fill(accent.opacity(0.16))
                            .frame(width: 56, height: 56)
                        Image(systemName: "sparkles")
                            .font(.system(size: DesignSystem.Typography.lg, weight: .semibold))
                            .foregroundColor(accent)
                    }

                    Text("Announcement")
                        .font(.system(size: DesignSystem.Typography.sm, weight: .semibold))
                        .foregroundColor(colors.neutral500)
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)
                .padding(.top, DesignSystem.Spacing.xl)
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
                .frame(height: configuration.height)
                .padding(configuration.padding)
                .background(resolvedBackgroundColor)
                .cornerRadius(configuration.cornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: configuration.cornerRadius)
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
}

/// A view displaying media (image or video) for the announcement.
private struct AnnouncementMediaView: View {
    let imageUrl: String

    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    private let fixedHeight: CGFloat = 200

    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(colors.border.opacity(0.3))
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
                    .shadowStyle(DesignSystem.Shadow.lg)
            case .failure:
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(colors.border.opacity(0.3))
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
                            .frame(width: DesignSystem.Spacing.xxxl, height: DesignSystem.Spacing.xxxl)
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
        .padding(DesignSystem.Spacing.md)
        .background(colors.background.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.md, style: .continuous)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.hairline)
        )
    }

    private var featureIconPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(colors.primary.opacity(0.12))
                .frame(width: DesignSystem.Spacing.xxxl, height: DesignSystem.Spacing.xxxl)

            Image(systemName: "sparkles")
                .font(.system(size: DesignSystem.Typography.lg))
                .foregroundColor(colors.primary)
        }
    }
}

#if DEBUG
struct AnnouncementCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(white: 0.15)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    AnnouncementCardView(
                        announcement: Announcement(
                            id: "1",
                            title: "Introducing agent mode",
                            subtitle: "ChatGPT can now do work on its own computer, from research and spreadsheets to booking reservations and more.",
                            features: [
                                AnnouncementFeature(
                                    id: "f1",
                                    title: "Research",
                                    description: "Can browse the web and gather information",
                                    imageUrl: nil
                                ),
                                AnnouncementFeature(
                                    id: "f2",
                                    title: "Spreadsheets",
                                    description: "Can work with data in spreadsheets",
                                    imageUrl: nil
                                ),
                                AnnouncementFeature(
                                    id: "f3",
                                    title: "Reservations",
                                    description: "Can help book reservations and appointments",
                                    imageUrl: nil
                                )
                            ],
                            version: "2.0.0",
                            imageUrl: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=600&fit=crop",
                            privacyNote: "Agent mode uses a remote browser and takes screenshots. You can take control at any time.",
                            learnMoreUrl: "https://example.com/learn-more",
                            createdAt: Date()
                        ),
                        configuration: .init(cornerRadius: 20),
                        onTryIt: {
                            print("Try it tapped")
                        },
                        onNotNow: {
                            print("Not now tapped")
                        }
                    )
                    .padding()

                    AnnouncementCardView(
                        announcement: Announcement(
                            id: "2",
                            title: "New Features Available",
                            subtitle: "We've added exciting new capabilities to help you get more done.",
                            features: [
                                AnnouncementFeature(
                                    id: "f4",
                                    title: "Enhanced Performance",
                                    description: "Faster and more responsive",
                                    imageUrl: nil
                                )
                            ],
                            version: "1.5.0",
                            imageUrl: nil,
                            privacyNote: nil,
                            learnMoreUrl: nil,
                            createdAt: Date()
                        ),
                        configuration: AnnouncementCardConfiguration(
                            backgroundColor: Color(white: 0.25),
                            primaryButton: .primary(title: "Get Started", backgroundColor: .blue, foregroundColor: .white),
                            secondaryButton: .text(title: "Maybe Later")
                        ),
                        onTryIt: {
                            print("Get Started tapped")
                        },
                        onNotNow: {
                            print("Maybe Later tapped")
                        }
                    )
                    .padding()

                    AnnouncementCardView(
                        announcement: Announcement(
                            id: "3",
                            title: "Information Only",
                            subtitle: "This announcement has no action buttons.",
                            features: [],
                            version: "1.0.0",
                            imageUrl: nil,
                            privacyNote: nil,
                            learnMoreUrl: nil,
                            createdAt: Date()
                        ),
                        configuration: .noButtons
                    )
                    .padding()
                }
            }
        }
        .previewDisplayName("Announcement Card")
    }
}
#endif
