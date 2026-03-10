import Foundation
import SwiftUI

@MainActor
@Observable
internal final class SupportViewModel {
    public private(set) var tickets: [SupportTicket] = []
    public private(set) var myTickets: [SupportTicket] = []
    public private(set) var isLoading = false
    public private(set) var isLoadingMyTickets = false
    public private(set) var isSubmitting = false
    public private(set) var error: AppGramError?

    private let supportService: SupportServiceProtocol
    private let userContextProvider: @Sendable () -> UserContext?
    private let ticketStorage = SupportTicketStorage.shared

    public init(supportService: SupportServiceProtocol, userContextProvider: @escaping @Sendable () -> UserContext?) {
        self.supportService = supportService
        self.userContextProvider = userContextProvider
    }

    public func loadTickets() async {
        logDebug("SupportViewModel: Loading support tickets from local storage")
        isLoading = true
        error = nil

        // Load tickets from local storage (no public API endpoint exists)
        tickets = ticketStorage.loadTickets()
        logInfo("SupportViewModel: Loaded \(tickets.count) support tickets from storage")

        isLoading = false
    }

    public func loadMyTickets() async {
        logDebug("SupportViewModel: Loading my support tickets from local storage")
        isLoadingMyTickets = true
        error = nil

        // Load tickets from local storage (same as loadTickets for now)
        // Tickets are stored locally when created
        myTickets = ticketStorage.loadTickets()
        logInfo("SupportViewModel: Loaded \(myTickets.count) my support tickets from storage")

        isLoadingMyTickets = false
    }

    public func createTicket(
        subject: String,
        description: String,
        priority: TicketPriority,
        email: String,
        attachmentUrls: [String]?
    ) async -> Bool {
        guard !subject.isEmpty else {
            logWarning("SupportViewModel: Validation failed - subject is empty")
            error = .validationError("Subject is required")
            return false
        }

        guard !description.isEmpty else {
            logWarning("SupportViewModel: Validation failed - description is empty")
            error = .validationError("Description is required")
            return false
        }

        guard !email.isEmpty else {
            logWarning("SupportViewModel: Validation failed - email is empty")
            error = .validationError("Email is required")
            return false
        }

        logInfo("SupportViewModel: Creating support ticket with subject: \(subject)")
        isSubmitting = true
        error = nil

        do {
            let ticket = try await supportService.createTicket(
                subject: subject,
                description: description,
                priority: priority,
                email: email,
                attachmentUrls: attachmentUrls
            )
            // Save to local storage
            ticketStorage.saveTicket(ticket)
            tickets.insert(ticket, at: 0)
            myTickets.insert(ticket, at: 0)
            logInfo("SupportViewModel: Successfully created ticket with id: \(ticket.id)")
            isSubmitting = false
            return true
        } catch let err as AppGramError {
            logError("SupportViewModel: Failed to create ticket - \(err.localizedDescription)")
            error = err
            isSubmitting = false
            return false
        } catch {
            logError("SupportViewModel: Network error creating ticket - \(error.localizedDescription)")
            self.error = .networkError(error.localizedDescription)
            isSubmitting = false
            return false
        }
    }

    public func uploadFile(_ data: Data, fileName: String, mimeType: String) async -> String? {
        logInfo("SupportViewModel: Uploading file: \(fileName)")
        do {
            let url = try await supportService.uploadFile(data, fileName: fileName, mimeType: mimeType)
            logInfo("SupportViewModel: Successfully uploaded file: \(url)")
            return url
        } catch let err as AppGramError {
            logError("SupportViewModel: Failed to upload file - \(err.localizedDescription)")
            error = err
            return nil
        } catch {
            logError("SupportViewModel: Network error uploading file - \(error.localizedDescription)")
            self.error = .networkError(error.localizedDescription)
            return nil
        }
    }

    public func clearError() {
        error = nil
    }

    public func refresh() async {
        await loadTickets()
    }

    public func refreshMyTickets() async {
        await loadMyTickets()
    }
}

@MainActor
@Observable
internal final class SupportDetailViewModel {
    public private(set) var ticket: SupportTicket
    public private(set) var messages: [SupportMessage] = []
    public private(set) var isLoading = false
    public private(set) var isSubmittingMessage = false
    public private(set) var error: AppGramError?

    public var newMessageText = ""

    private let supportService: SupportServiceProtocol

    public init(ticket: SupportTicket, supportService: SupportServiceProtocol) {
        self.ticket = ticket
        self.supportService = supportService
        // Initialize messages from ticket if available
        self.messages = ticket.messages ?? []
    }

    public func loadMessages() async {
        isLoading = true
        error = nil

        // Use access token if available (required for portal API)
        guard let token = ticket.accessToken, !token.isEmpty else {
            // No token available - just use messages from ticket
            messages = ticket.messages ?? []
            isLoading = false
            return
        }

        do {
            // Fetch messages directly using token
            messages = try await supportService.getMessagesWithToken(
                ticketId: ticket.id,
                token: token
            )
            logInfo("SupportDetailViewModel: Loaded \(messages.count) messages for ticket \(ticket.id)")
        } catch let err as AppGramError {
            // If messages endpoint fails, try to get them from ticket detail
            logDebug("SupportDetailViewModel: Messages endpoint failed, trying ticket detail")
            do {
                let updatedTicket = try await supportService.getTicketWithToken(
                    ticketId: ticket.id,
                    token: token
                )
                ticket = updatedTicket
                messages = updatedTicket.messages ?? []
                SupportTicketStorage.shared.updateTicket(updatedTicket)
            } catch {
                self.error = err
            }
        } catch {
            self.error = .networkError(error.localizedDescription)
        }

        isLoading = false
    }

    public func addMessage(attachmentUrls: [String]? = nil) async -> Bool {
        let content = newMessageText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else {
            error = .validationError("Message cannot be empty")
            return false
        }

        // Require access token for adding messages
        guard let token = ticket.accessToken, !token.isEmpty else {
            error = .unauthorized
            return false
        }

        isSubmittingMessage = true
        error = nil

        do {
            let message = try await supportService.addMessageWithToken(
                ticketId: ticket.id,
                token: token,
                content: content
            )
            messages.append(message)
            newMessageText = ""
            isSubmittingMessage = false
            return true
        } catch let err as AppGramError {
            error = err
            isSubmittingMessage = false
            return false
        } catch {
            self.error = .networkError(error.localizedDescription)
            isSubmittingMessage = false
            return false
        }
    }

    public func clearError() {
        error = nil
    }

    public func refresh() async {
        await loadMessages()
    }
}
