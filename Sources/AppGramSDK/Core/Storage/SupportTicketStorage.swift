import Foundation

/// Manages local storage of support tickets.
/// Mirrors the React Native SDK's approach using AsyncStorage.
internal final class SupportTicketStorage: @unchecked Sendable {
    private static let storageKey = "com.appgram.support_tickets"
    private static let maxTickets = 50

    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    static let shared = SupportTicketStorage()

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }

    /// Load all stored tickets
    func loadTickets() -> [SupportTicket] {
        guard let data = defaults.data(forKey: Self.storageKey) else {
            return []
        }

        do {
            let tickets = try decoder.decode([SupportTicket].self, from: data)
            logDebug("SupportTicketStorage: Loaded \(tickets.count) tickets from storage")
            return tickets
        } catch {
            logError("SupportTicketStorage: Failed to decode tickets - \(error.localizedDescription)")
            return []
        }
    }

    /// Save a new ticket to storage
    func saveTicket(_ ticket: SupportTicket) {
        var tickets = loadTickets()

        // Add new ticket at the beginning
        tickets.insert(ticket, at: 0)

        // Keep only the most recent tickets
        if tickets.count > Self.maxTickets {
            tickets = Array(tickets.prefix(Self.maxTickets))
        }

        saveTickets(tickets)
        logInfo("SupportTicketStorage: Saved ticket \(ticket.id) to storage")
    }

    /// Clear all stored tickets
    func clearTickets() {
        defaults.removeObject(forKey: Self.storageKey)
        logInfo("SupportTicketStorage: Cleared all tickets from storage")
    }

    /// Update a ticket's status in storage
    func updateTicket(_ ticket: SupportTicket) {
        var tickets = loadTickets()

        if let index = tickets.firstIndex(where: { $0.id == ticket.id }) {
            tickets[index] = ticket
            saveTickets(tickets)
            logDebug("SupportTicketStorage: Updated ticket \(ticket.id) in storage")
        }
    }

    private func saveTickets(_ tickets: [SupportTicket]) {
        do {
            let data = try encoder.encode(tickets)
            defaults.set(data, forKey: Self.storageKey)
        } catch {
            logError("SupportTicketStorage: Failed to encode tickets - \(error.localizedDescription)")
        }
    }
}
