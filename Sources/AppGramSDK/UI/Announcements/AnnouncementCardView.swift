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
        VStack(spacing: 0) {
            // Media preview (image or video) at the top
            if let imageUrl = announcement.imageUrl {
                AnnouncementMediaView(imageUrl: imageUrl)
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.top, DesignSystem.Spacing.xl)
            }

            // Content area
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xl) {
                // Title
                Text(announcement.title)
                    .font(.system(size: configuration.titleFontSize, weight: DesignSystem.Typography.bold))
                    .foregroundColor(configuration.titleColor ?? .white)
                    .padding(.top, DesignSystem.Spacing.xxl)
                    .padding(.horizontal, DesignSystem.Spacing.xl)

                // Description paragraphs
                VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
                    if let subtitle = announcement.subtitle {
                        Text(subtitle)
                            .font(.system(size: configuration.descriptionFontSize))
                            .foregroundColor(configuration.descriptionColor ?? .white)
                            .lineSpacing(DesignSystem.Spacing.xs)
                    }

                    // Additional description from features
                    if !announcement.features.isEmpty {
                        let featureDescriptions = announcement.features.compactMap { $0.description }.joined(separator: " ")
                        if !featureDescriptions.isEmpty {
                            Text(featureDescriptions)
                                .font(.system(size: configuration.descriptionFontSize))
                                .foregroundColor(configuration.descriptionColor ?? .white)
                                .lineSpacing(DesignSystem.Spacing.xs)
                        }
                    }
                }
                .padding(.horizontal, DesignSystem.Spacing.xl)

                // Privacy notice
                if let privacyNote = announcement.privacyNote {
                    HStack(spacing: DesignSystem.Spacing.xs) {
                        Text(privacyNote)
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                            .foregroundColor(.white.opacity(DesignSystem.Opacity.subtle))

                        if let learnMoreUrl = announcement.learnMoreUrl {
                            Button(action: {
                                if let url = URL(string: learnMoreUrl) {
                                    #if canImport(UIKit)
                                    UIApplication.shared.open(url)
                                    #endif
                                }
                            }) {
                                Text("Learn more")
                                    .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.medium))
                                    .foregroundColor(.white)
                            }
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                }

                Spacer()

                // Action buttons
                if configuration.primaryButton != nil || configuration.secondaryButton != nil {
                    VStack(spacing: DesignSystem.Spacing.lg) {
                        // Primary button
                        if let primaryButton = configuration.primaryButton {
                            ConfigurableButton(configuration: primaryButton, action: onTryIt ?? primaryButton.action)
                        }

                        // Secondary button
                        if let secondaryButton = configuration.secondaryButton {
                            ConfigurableButton(configuration: secondaryButton, action: onNotNow ?? secondaryButton.action)
                        }
                    }
                    .padding(.horizontal, DesignSystem.Spacing.xl)
                    .padding(.bottom, DesignSystem.Spacing.xxl)
                }
            }
        }
        .background(configuration.backgroundColor ?? Color(white: 0.2))
        .cornerRadius(configuration.cornerRadius)
        .layeredShadow()
    }
}

/// A button view that uses ButtonConfiguration for styling.
private struct ConfigurableButton: View {
    let configuration: ButtonConfiguration
    let action: (() -> Void)?
    
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
                        .strokeBorder(Color.clear, lineWidth: 0)
                )
        }
    }
    
    private var resolvedBackgroundColor: Color? {
        switch configuration.style {
        case .primary:
            return configuration.backgroundColor ?? .white
        case .secondary:
            return nil // Transparent background
        case .text:
            return nil // Transparent background
        case .custom:
            return configuration.backgroundColor
        }
    }
    
    private var resolvedForegroundColor: Color {
        switch configuration.style {
        case .primary:
            return configuration.foregroundColor ?? .black
        case .secondary, .text:
            return configuration.foregroundColor ?? .white
        case .custom:
            return configuration.foregroundColor ?? .white
        }
    }
}

/// A view displaying media (image or video) for the announcement.
private struct AnnouncementMediaView: View {
    let imageUrl: String
    
    private let fixedHeight: CGFloat = 200

    var body: some View {
        AsyncImage(url: URL(string: imageUrl)) { phase in
            switch phase {
            case .empty:
                // Loading placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(Color(white: 0.3))
                        .frame(height: fixedHeight)

                    ProgressView()
                        .tint(.white)
                }
            case .success(let image):
                // Display the image with fixed height to prevent view resizing
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: fixedHeight)
                    .clipped()
                    .cornerRadius(DesignSystem.CornerRadius.lg)
                    .shadowStyle(DesignSystem.Shadow.lg)
            case .failure:
                // Error placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(Color(white: 0.3))
                        .frame(height: fixedHeight)

                    VStack(spacing: DesignSystem.Spacing.sm) {
                        Image(systemName: "photo")
                            .font(.system(size: DesignSystem.Typography.xxxl))
                            .foregroundColor(.white.opacity(DesignSystem.Opacity.disabled))
                        Text("Image unavailable")
                            .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                            .foregroundColor(.white.opacity(DesignSystem.Opacity.disabled))
                    }
                }
            @unknown default:
                // Fallback placeholder
                ZStack {
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.lg)
                        .fill(Color(white: 0.3))
                        .frame(height: fixedHeight)

                    ProgressView()
                        .tint(.white)
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
            // Feature icon or image
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

            // Feature content
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.xs) {
                Text(feature.title)
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                    .foregroundColor(colors.text)

                if let description = feature.description {
                    Text(description)
                        .font(.system(size: DesignSystem.Typography.sm, weight: DesignSystem.Typography.regular))
                        .foregroundColor(colors.secondary)
                        .lineSpacing(DesignSystem.Spacing.xs)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var featureIconPlaceholder: some View {
        ZStack {
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.sm)
                .fill(Color.blue.opacity(DesignSystem.Opacity.disabled))
                .frame(width: DesignSystem.Spacing.xxxl, height: DesignSystem.Spacing.xxxl)

            Image(systemName: "star.fill")
                .font(.system(size: DesignSystem.Typography.lg))
                .foregroundColor(.blue)
        }
    }
}

#if DEBUG
struct AnnouncementCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            // Dark background to match the modal
            Color(white: 0.15)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // Preview with image and default buttons
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
                    
                    // Preview without image and custom buttons
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
                    
                    // Preview with no buttons
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



