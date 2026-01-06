import Foundation

/// Errors that can occur when using the AppGram SDK.
///
/// ## Discussion
/// This enumeration represents all possible error conditions that can arise during SDK operations,
/// including configuration issues, network problems, and API errors.
///
/// ## Example
/// ```swift
/// do {
///     let service = try AppGramSDK.shared.getFeedbackService()
/// } catch AppGramError.notConfigured {
///     print("SDK must be configured first")
/// } catch AppGramError.networkError(let message) {
///     print("Network error: \(message)")
/// }
/// ```
public enum AppGramError: Error, LocalizedError, Sendable {
    case notConfigured
    case networkError(String)
    case invalidResponse
    case decodingError(String)
    case validationError(String)
    case uploadFailed
    case unauthorized
    case forbidden
    case notFound
    case serverError(Int)

    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "SDK not configured. Call AppGramSDK.shared.configure() first."
        case .networkError(let message):
            return "Network error: \(message)"
        case .invalidResponse:
            return "Invalid server response"
        case .decodingError(let message):
            return "Failed to decode response: \(message)"
        case .validationError(let message):
            return message
        case .uploadFailed:
            return "File upload failed"
        case .unauthorized:
            return "Unauthorized access"
        case .forbidden:
            return "This form is not available"
        case .notFound:
            return "Resource not found"
        case .serverError(let code):
            return "Server error (HTTP \(code))"
        }
    }
}
