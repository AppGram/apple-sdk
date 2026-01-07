import SwiftUI

/// A modal view displaying announcements with paging support.
///
/// ## Discussion
/// This view presents announcements in a modal overlay with a dark dimmed background.
/// When multiple announcements are available, users can swipe between them.
/// The modal follows Apple's iOS design patterns with rounded corners and smooth animations.
public struct AnnouncementModalView: View {
    let announcements: [Announcement]
    let cardConfiguration: AnnouncementCardConfiguration
    let onDismiss: () -> Void
    let onAction: (Announcement) -> Void

    @State private var currentPage: Int = 0
    @State private var isPresented: Bool = false
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    public init(
        announcements: [Announcement],
        cardConfiguration: AnnouncementCardConfiguration = .default,
        onDismiss: @escaping () -> Void,
        onAction: @escaping (Announcement) -> Void = { _ in }
    ) {
        self.announcements = announcements
        self.cardConfiguration = cardConfiguration
        self.onDismiss = onDismiss
        self.onAction = onAction
    }

    public var body: some View {
        ZStack {
            backgroundView
                .onTapGesture {
                    dismissModal()
                }

            VStack(spacing: 0) {
                Spacer()

                HStack {
                    Spacer()
                    Button(action: dismissModal) {
                        Image(systemName: "xmark")
                            .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.semibold))
                            .foregroundColor(colors.text.opacity(DesignSystem.Opacity.subtle))
                            .frame(width: DesignSystem.Spacing.xxxl, height: DesignSystem.Spacing.xxxl)
                            .background(colors.cardBackground.opacity(0.95))
                            .clipShape(Circle())
                            .overlay(
                                Circle()
                                    .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                            )
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.trailing, DesignSystem.Spacing.xl)
                }

                if announcements.count == 1 {
                    singleAnnouncementView
                } else {
                    pagedAnnouncementsView
                }
            }
        }
        .opacity(isPresented ? 1 : 0)
        .scaleEffect(isPresented ? 1 : 0.96)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPresented = true
            }
        }
        .allowsHitTesting(isPresented)
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [colors.background, colors.neutral100],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Circle()
                .fill(colors.neutral200.opacity(0.3))
                .frame(width: 320, height: 320)
                .offset(x: -180, y: -140)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 160)
                .fill(colors.neutral200.opacity(0.2))
                .frame(width: 300, height: 180)
                .rotationEffect(.degrees(-10))
                .offset(x: 140, y: 120)
        )
        .overlay(Color.black.opacity(colorScheme == .dark ? 0.45 : 0.2))
        .ignoresSafeArea()
    }

    private var singleAnnouncementView: some View {
        AnnouncementCardView(
            announcement: announcements[0],
            configuration: cardConfiguration,
            onTryIt: {
                onAction(announcements[0])
                dismissModal()
            },
            onNotNow: {
                dismissModal()
            }
        )
        .padding(cardConfiguration.modalPadding)
        .background(sheetBackground)
    }

    private var pagedAnnouncementsView: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(announcements.enumerated()), id: \.element.id) { index, announcement in
                    ScrollView {
                        AnnouncementCardView(
                            announcement: announcement,
                            configuration: cardConfiguration,
                            onTryIt: {
                                onAction(announcement)
                                dismissModal()
                            },
                            onNotNow: {
                                dismissModal()
                            }
                        )
                        .padding(cardConfiguration.modalPadding)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: UIScreen.main.bounds.height * 0.72)

            if announcements.count > 1 && cardConfiguration.pageIndicatorConfiguration.isVisible {
                if let customView = cardConfiguration.pageIndicatorConfiguration.customView {
                    customView(currentPage, announcements.count)
                        .padding(.bottom, cardConfiguration.pageIndicatorConfiguration.bottomPadding ?? DesignSystem.Spacing.xl)
                } else {
                    HStack(spacing: cardConfiguration.pageIndicatorConfiguration.spacing ?? DesignSystem.Spacing.md) {
                        ForEach(0..<announcements.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index
                                    ? (cardConfiguration.pageIndicatorConfiguration.activeColor ?? colors.text)
                                    : (cardConfiguration.pageIndicatorConfiguration.inactiveColor ?? colors.text.opacity(DesignSystem.Opacity.disabled)))
                                .frame(
                                    width: cardConfiguration.pageIndicatorConfiguration.size ?? DesignSystem.Spacing.md,
                                    height: cardConfiguration.pageIndicatorConfiguration.size ?? DesignSystem.Spacing.md
                                )
                                .animation(.easeInOut, value: currentPage)
                        }
                    }
                    .padding(.bottom, cardConfiguration.pageIndicatorConfiguration.bottomPadding ?? DesignSystem.Spacing.lg)
                }
            }
        }
        .background(sheetBackground)
    }

    private var sheetBackground: some View {
        RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
            .fill(colors.cardBackground)
            .overlay(
                RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous)
                    .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
            )
            .clipShape(RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl, style: .continuous))
            .shadow(color: colors.text.opacity(0.1), radius: 24, x: 0, y: -8)
            .ignoresSafeArea(edges: .bottom)
            .padding(.horizontal, DesignSystem.Spacing.lg)
            .padding(.bottom, DesignSystem.Spacing.lg)
    }

    private func dismissModal() {
        onDismiss()
    }
}

#if DEBUG
struct AnnouncementModalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AnnouncementModalView(
                announcements: [
                    Announcement(
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
                    )
                ],
                cardConfiguration: .init(cornerRadius: 20),
                onDismiss: {
                    print("Dismissed")
                },
                onAction: { announcement in
                    print("Action on: \(announcement.title)")
                }
            )
            .previewDisplayName("Single Announcement")

            AnnouncementModalView(
                announcements: [
                    Announcement(
                        id: "1",
                        title: "New Feature Available",
                        subtitle: "We've added exciting new capabilities to help you get more done.",
                        features: [
                            AnnouncementFeature(
                                id: "f1",
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
                    Announcement(
                        id: "2",
                        title: "Introducing agent mode",
                        subtitle: "ChatGPT can now work autonomously on its own computer",
                        features: [
                            AnnouncementFeature(
                                id: "f2",
                                title: "Research",
                                description: "Can browse the web and gather information",
                                imageUrl: nil
                            )
                        ],
                        version: "2.0.0",
                        imageUrl: "https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=800&h=600&fit=crop",
                        privacyNote: "Agent mode uses a remote browser and takes screenshots.",
                        learnMoreUrl: "https://example.com/learn-more",
                        createdAt: Date()
                    )
                ],
                cardConfiguration: AnnouncementCardConfiguration(
                    backgroundColor: Color(white: 0.25),
                    primaryButton: .primary(title: "Get Started", backgroundColor: .blue, foregroundColor: .white),
                    secondaryButton: .text(title: "Maybe Later"),
                    cornerRadius: 16
                ),
                onDismiss: {
                    print("Dismissed")
                },
                onAction: { announcement in
                    print("Action on: \(announcement.title)")
                }
            )
            .previewDisplayName("Multiple Announcements")

            AnnouncementModalView(
                announcements: [
                    Announcement(
                        id: "3",
                        title: "Information Only",
                        subtitle: "This announcement has no action buttons and uses custom styling.",
                        features: [],
                        version: "1.0.0",
                        imageUrl: nil,
                        privacyNote: nil,
                        learnMoreUrl: nil,
                        createdAt: Date()
                    )
                ],
                cardConfiguration: .noButtons,
                onDismiss: {
                    print("Dismissed")
                },
                onAction: { _ in }
            )
            .previewDisplayName("No Buttons")
        }
    }
}
#endif
