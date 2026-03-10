import SwiftUI

public struct SupportTicketListView: View {
    @Environment(\.appGramTheme) private var theme
    @Environment(\.colorScheme) private var colorScheme

    @State private var viewModel: SupportViewModel
    @State private var showingSubmitSheet = false
    @State private var selectedTicket: SupportTicket?
    @State private var selectedTab: SupportTab = .newSupport

    private let supportService: SupportServiceProtocol
    private let userContextProvider: @Sendable () -> UserContext?

    private var colors: ColorPalette {
        theme.resolvedColors(for: colorScheme)
    }

    enum SupportTab: String, CaseIterable {
        case newSupport = "New Support"
        case myTickets = "My Tickets"
    }

    public init(supportService: SupportServiceProtocol, userContextProvider: @escaping @Sendable () -> UserContext?) {
        self.supportService = supportService
        self.userContextProvider = userContextProvider
        _viewModel = State(initialValue: SupportViewModel(supportService: supportService, userContextProvider: userContextProvider))
    }

    public var body: some View {
        NavigationStack {
            ZStack {
                backgroundView

                VStack(spacing: 0) {
                    headerView

                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        newSupportView
                            .tag(SupportTab.newSupport)

                        myTicketsView
                            .tag(SupportTab.myTickets)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("")
                }
            }
            .sheet(item: $selectedTicket) { ticket in
                NavigationStack {
                    SupportTicketDetailView(
                        ticket: ticket,
                        supportService: supportService
                    )
                }
            }
        }
        .task {
            await viewModel.loadTickets()
            await viewModel.loadMyTickets()
        }
    }

    private var backgroundView: some View {
        LinearGradient(
            colors: [colors.background, colors.neutral100],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(
            Circle()
                .fill(colors.neutral200.opacity(0.4))
                .frame(width: 240, height: 240)
                .offset(x: -140, y: -120)
        )
        .ignoresSafeArea()
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: DesignSystem.Spacing.sm) {
                Text("Support")
                    .font(.system(size: 34, weight: .bold, design: .serif))
                    .foregroundColor(colors.text)

                Text("Resolve issues fast with context and clear status.")
                    .font(.system(size: DesignSystem.Typography.base, weight: DesignSystem.Typography.regular))
                    .foregroundColor(colors.neutral500)
            }

            Picker("Support Tab", selection: $selectedTab) {
                ForEach(SupportTab.allCases, id: \.self) { tab in
                    Text(tab.rawValue).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .tint(colors.primary)
        }
        .padding(DesignSystem.Spacing.lg)
        .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
        .overlay(
            RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
        )
        .padding(.horizontal, DesignSystem.Spacing.lg)
        .padding(.top, DesignSystem.Spacing.md)
        .padding(.bottom, DesignSystem.Spacing.md)
    }

    @ViewBuilder
    private var newSupportView: some View {
        SupportFormSelectionView(
            supportService: supportService,
            userContextProvider: userContextProvider,
            formId: nil,
            embedded: true
        ) {
            // Dismiss handler - not needed here since it's embedded
        }
    }

    @ViewBuilder
    private var myTicketsView: some View {
        if viewModel.isLoadingMyTickets && viewModel.myTickets.isEmpty {
            supportStateContainer {
                LoadingView()
            }
        } else if let error = viewModel.error, viewModel.myTickets.isEmpty {
            supportStateContainer {
                ErrorView(error: error) {
                    await viewModel.loadMyTickets()
                }
            }
        } else if viewModel.myTickets.isEmpty {
            supportStateContainer {
                EmptyStateView(
                    icon: "ticket",
                    title: "No Tickets",
                    message: "You don't have any support tickets yet.",
                    actionTitle: "Create Ticket"
                ) {
                    showingSubmitSheet = true
                }
            }
        } else {
            myTicketsList
        }
    }

    private var ticketList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(viewModel.tickets) { ticket in
                    SupportTicketCard(ticket: ticket)
                        .onTapGesture {
                            selectedTicket = ticket
                        }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
        .refreshable {
            await viewModel.refresh()
        }
    }

    private var myTicketsList: some View {
        ScrollView {
            LazyVStack(spacing: DesignSystem.Spacing.md) {
                ForEach(viewModel.myTickets) { ticket in
                    SupportTicketCard(ticket: ticket)
                        .onTapGesture {
                            selectedTicket = ticket
                        }
                }
            }
            .padding(DesignSystem.Spacing.lg)
        }
        .background(colors.background)
        .refreshable {
            await viewModel.refreshMyTickets()
        }
    }

    private func supportStateContainer<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(spacing: DesignSystem.Spacing.lg) {
            Spacer(minLength: 0)
            content()
                .padding(DesignSystem.Spacing.lg)
                .frame(maxWidth: .infinity)
                .background(colors.cardBackground.opacity(0.95), in: RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl))
                .overlay(
                    RoundedRectangle(cornerRadius: DesignSystem.CornerRadius.xl)
                        .strokeBorder(colors.border, lineWidth: DesignSystem.BorderWidth.thin)
                )
                .padding(.horizontal, DesignSystem.Spacing.lg)
            Spacer(minLength: 0)
        }
    }
}
