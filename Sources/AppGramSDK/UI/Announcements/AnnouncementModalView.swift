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
            // Dark overlay background with opacity (matching ChatGPT style)
            Color.black.opacity(0.6)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissModal()
                }

            // Modal content - full screen dark overlay
            VStack(spacing: 0) {
                // Close button at top right
                HStack {
                    Spacer()
                    Button(action: dismissModal) {
                        Image(systemName: "xmark")
                            .font(.system(size: DesignSystem.Typography.lg, weight: DesignSystem.Typography.medium))
                            .foregroundColor(.white.opacity(DesignSystem.Opacity.subtle))
                            .frame(width: DesignSystem.Spacing.xxxl, height: DesignSystem.Spacing.xxxl)
                            .background(Color.white.opacity(DesignSystem.Opacity.disabled))
                            .clipShape(Circle())
                    }
                    .padding(.top, DesignSystem.Spacing.lg)
                    .padding(.trailing, DesignSystem.Spacing.xl)
                }

                // Pager view
                if announcements.count == 1 {
                    // Single announcement
                    singleAnnouncementView
                } else {
                    // Multiple announcements with paging
                    pagedAnnouncementsView
                }
            }
        }
        .opacity(isPresented ? 1 : 0)
        .scaleEffect(isPresented ? 1 : 0.95)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPresented = true
            }
        }
        .allowsHitTesting(isPresented)
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
    }

    private var pagedAnnouncementsView: some View {
        VStack(spacing: 0) {
            // Tab view for paging
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
            .frame(maxHeight: UIScreen.main.bounds.height * 0.9)

            // Page indicators
            if announcements.count > 1 && cardConfiguration.pageIndicatorConfiguration.isVisible {
                if let customView = cardConfiguration.pageIndicatorConfiguration.customView {
                    // Custom indicator view
                    customView(currentPage, announcements.count)
                        .padding(.bottom, cardConfiguration.pageIndicatorConfiguration.bottomPadding ?? DesignSystem.Spacing.xl)
                } else {
                    // Default styled indicators
                    HStack(spacing: cardConfiguration.pageIndicatorConfiguration.spacing ?? DesignSystem.Spacing.md) {
                        ForEach(0..<announcements.count, id: \.self) { index in
                            Circle()
                                .fill(currentPage == index
                                    ? (cardConfiguration.pageIndicatorConfiguration.activeColor ?? .white)
                                    : (cardConfiguration.pageIndicatorConfiguration.inactiveColor ?? Color.white.opacity(DesignSystem.Opacity.disabled)))
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
    }

    private func dismissModal() {
        // Immediately call onDismiss to dismiss the UIKit view controller
        // The animation will be handled by UIKit's dismiss transition
        onDismiss()
    }
}

#if DEBUG
struct AnnouncementModalView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Preview with single announcement and default configuration
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
            
            // Preview with multiple announcements
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
            
            // Preview with custom configuration and no buttons
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
