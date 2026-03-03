import Foundation

/// Protocol for interacting with support ticket functionality.
///
/// ## Discussion
/// The support service provides methods to create and manage support tickets,
/// including creating tickets, viewing ticket lists, managing messages, and
/// uploading file attachments.
///
/// ## Example
/// ```swift
/// let service = try AppGramSDK.shared.getSupportService()
/// let tickets = try await service.getMyTickets(email: "user@example.com", externalUserId: nil, page: 1, perPage: 20)
/// ```
public protocol SupportServiceProtocol: Sendable {
    func getTickets() async throws -> [SupportTicket]
    func getMyTickets(email: String?, externalUserId: String?, page: Int, perPage: Int) async throws -> [SupportTicket]
    func getTicket(id: String) async throws -> SupportTicket
    func createTicket(
        subject: String,
        description: String,
        priority: TicketPriority,
        email: String,
        attachmentUrls: [String]?
    ) async throws -> SupportTicket
    func getMessages(ticketId: String) async throws -> [SupportMessage]
    func addMessage(ticketId: String, content: String, attachmentUrls: [String]?) async throws -> SupportMessage
    func uploadFile(_ data: Data, fileName: String, mimeType: String) async throws -> String
    func getSupportForms() async throws -> [SupportForm]
    func getSupportForm(formId: String) async throws -> SupportForm
    func submitSupportForm(
        formId: String,
        subject: String,
        description: String,
        data: [String: String],
        userEmail: String?,
        userName: String?
    ) async throws -> Void

    // Magic Link Authentication
    func sendMagicLink(userEmail: String) async throws -> MagicLinkResponse
    func verifyMagicLinkToken(_ token: String) async throws -> MagicLinkVerifyResponse
    func getTicketWithToken(ticketId: String, token: String) async throws -> SupportTicket
    func addMessageWithToken(ticketId: String, token: String, content: String) async throws -> SupportMessage
}

internal actor SupportService: SupportServiceProtocol {
    private let apiClient: APIClient
    private let projectId: String
    private let userContextProvider: @Sendable () -> UserContext?

    public init(
        apiClient: APIClient,
        projectId: String,
        userContextProvider: @escaping @Sendable () -> UserContext?
    ) {
        self.apiClient = apiClient
        self.projectId = projectId
        self.userContextProvider = userContextProvider
    }

    public func getTickets() async throws -> [SupportTicket] {
        logDebug("Getting support tickets")
        let response: SupportTicketsResponse = try await apiClient.get(
            endpoint: .supportTickets(projectId: projectId)
        )
        logInfo("Fetched \(response.tickets.count) support tickets")
        return response.tickets
    }

    public func getMyTickets(email: String?, externalUserId: String?, page: Int = 1, perPage: Int = 20) async throws -> [SupportTicket] {
        logDebug("Getting my support tickets, email: \(String(describing: email)), externalUserId: \(String(describing: externalUserId))")
        let filters = SupportRequestFilters(
            email: email,
            externalUserId: externalUserId,
            page: page,
            perPage: perPage
        )
        let response: SupportTicketsResponse = try await apiClient.get(
            endpoint: .supportRequestsMy(projectId: projectId, email: email, externalUserId: externalUserId, page: page, perPage: perPage),
            supportRequestFilters: filters
        )
        logInfo("Fetched \(response.tickets.count) support tickets for user")
        return response.tickets
    }

    public func getTicket(id: String) async throws -> SupportTicket {
        logDebug("Getting support ticket with id: \(id)")
        let response: APIResponse<SupportTicket> = try await apiClient.get(endpoint: .supportTicket(id: id))
        logDebug("Fetched support ticket: \(response.data.subject)")
        return response.data
    }

    public func createTicket(
        subject: String,
        description: String,
        priority: TicketPriority,
        email: String,
        attachmentUrls: [String]?
    ) async throws -> SupportTicket {
        logInfo("Creating support ticket with subject: \(subject), priority: \(priority)")
        let userContext = userContextProvider()

        let request = CreateTicketRequest(
            subject: subject,
            description: description,
            priority: priority,
            userEmail: email,
            userName: userContext?.name,
            userId: userContext?.userId,
            projectId: projectId,
            attachmentUrls: attachmentUrls
        )

        let response: APIResponse<SupportTicket> = try await apiClient.post(endpoint: .createSupportTicket, body: request)
        logInfo("Successfully created support ticket with id: \(response.data.id)")
        return response.data
    }

    public func getMessages(ticketId: String) async throws -> [SupportMessage] {
        logDebug("Getting messages for ticket: \(ticketId)")
        let response: SupportMessagesResponse = try await apiClient.get(
            endpoint: .supportMessages(ticketId: ticketId)
        )
        logInfo("Fetched \(response.messages.count) messages for ticket: \(ticketId)")
        return response.messages
    }

    public func addMessage(
        ticketId: String,
        content: String,
        attachmentUrls: [String]?
    ) async throws -> SupportMessage {
        logInfo("Adding message to ticket: \(ticketId)")
        let userContext = userContextProvider()

        let request = CreateMessageRequest(
            ticketId: ticketId,
            content: content,
            authorName: userContext?.name,
            authorEmail: userContext?.email,
            attachmentUrls: attachmentUrls
        )

        let response: APIResponse<SupportMessage> = try await apiClient.post(endpoint: .createSupportMessage, body: request)
        logInfo("Successfully added message to ticket: \(ticketId)")
        return response.data
    }

    public func uploadFile(_ data: Data, fileName: String, mimeType: String) async throws -> String {
        logInfo("Uploading file: \(fileName) for support ticket")
        let response = try await apiClient.uploadFile(data, fileName: fileName, mimeType: mimeType)
        logInfo("Successfully uploaded file: \(response.url)")
        return response.url
    }

    public func getSupportForms() async throws -> [SupportForm] {
        logDebug("Getting support forms")
        let response: SupportFormsAPIResponse = try await apiClient.get(
            endpoint: .supportForms(projectId: projectId)
        )
        logInfo("Fetched \(response.data.supportForms.count) support forms")
        return Array(response.data.supportForms.values)
    }

    public func getSupportForm(formId: String) async throws -> SupportForm {
        logDebug("Getting support form with id: \(formId)")
        let response: APIResponse<SupportFormDetailData> = try await apiClient.get(
            endpoint: .supportForm(projectId: projectId, formId: formId)
        )
        logInfo("Fetched support form: \(response.data.supportForm.name)")
        return response.data.supportForm
    }

    public func submitSupportForm(
        formId: String,
        subject: String,
        description: String,
        data: [String: String],
        userEmail: String?,
        userName: String?
    ) async throws -> Void {
        logInfo("Submitting support form: \(formId)")
        let userContext = userContextProvider()

        let request = SupportFormSubmission(
            formId: formId,
            subject: subject,
            description: description,
            data: data,
            userEmail: userEmail ?? userContext?.email,
            userName: userName ?? userContext?.name
        )

        _ = try await apiClient.post(endpoint: .submitSupportForm(projectId: projectId, formId: formId), body: request)
        logInfo("Successfully submitted support form: \(formId)")
    }

    // MARK: - Magic Link Authentication

    public func sendMagicLink(userEmail: String) async throws -> MagicLinkResponse {
        logInfo("Sending magic link to: \(userEmail)")
        let request = MagicLinkRequest(projectId: projectId, userEmail: userEmail)
        let response: MagicLinkResponse = try await apiClient.post(endpoint: .supportMagicLink, body: request)
        logInfo("Successfully sent magic link")
        return response
    }

    public func verifyMagicLinkToken(_ token: String) async throws -> MagicLinkVerifyResponse {
        logDebug("Verifying magic link token")
        let response: APIResponse<MagicLinkVerifyResponse> = try await apiClient.get(
            endpoint: .supportVerifyToken,
            token: token
        )
        logInfo("Successfully verified magic link token, found \(response.data.tickets.count) tickets")
        return response.data
    }

    public func getTicketWithToken(ticketId: String, token: String) async throws -> SupportTicket {
        logDebug("Getting ticket with token: \(ticketId)")
        let response: APIResponse<SupportTicket> = try await apiClient.get(
            endpoint: .supportTicketWithToken(ticketId: ticketId),
            token: token
        )
        logInfo("Successfully fetched ticket with token: \(response.data.subject)")
        return response.data
    }

    public func addMessageWithToken(ticketId: String, token: String, content: String) async throws -> SupportMessage {
        logInfo("Adding message with token to ticket: \(ticketId)")
        let request = AddMessageWithTokenRequest(content: content)

        // Build URL with token query parameter
        let response: APIResponse<SupportMessage> = try await apiClient.post(
            endpoint: .supportMessageWithToken(ticketId: ticketId),
            body: request
        )
        logInfo("Successfully added message with token to ticket: \(ticketId)")
        return response.data
    }
}
