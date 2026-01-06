import Foundation

/// Utility for sanitizing form input data
public struct InputSanitizer {
    public init() {}
    
    /// Sanitize a string value by trimming whitespace and removing potentially dangerous characters
    /// - Parameter value: The input value to sanitize
    /// - Returns: Sanitized string
    public func sanitize(_ value: String) -> String {
        // Trim whitespace and newlines
        var sanitized = value.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove null bytes
        sanitized = sanitized.replacingOccurrences(of: "\0", with: "")
        
        // Remove control characters except newlines and tabs (for textarea fields)
        let controlCharacters = CharacterSet.controlCharacters
        let allowedControlCharacters = CharacterSet(charactersIn: "\n\t\r")
        sanitized = sanitized.unicodeScalars.filter { scalar in
            // Keep if it's not a control character, or if it's an allowed control character
            return !controlCharacters.contains(scalar) || allowedControlCharacters.contains(scalar)
        }.map { String($0) }.joined()
        
        return sanitized
    }
    
    /// Sanitize a dictionary of form data
    /// - Parameter data: Dictionary of field IDs to values
    /// - Returns: Sanitized dictionary
    public func sanitize(_ data: [String: String]) -> [String: String] {
        return data.mapValues { sanitize($0) }
    }
}
