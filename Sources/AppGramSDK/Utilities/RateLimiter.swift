import Foundation

/// Rate limiter for contact form submissions
/// Limits submissions to max 10 per hour per form
public actor RateLimiter {
    private let maxSubmissions: Int
    private let timeWindow: TimeInterval
    private let storageKey: String
    
    private struct SubmissionRecord: Codable {
        let timestamps: [Date]
    }
    
    public init(
        maxSubmissions: Int = 10,
        timeWindow: TimeInterval = 3600, // 1 hour in seconds
        storageKey: String = "com.appgram.sdk.contactFormSubmissions"
    ) {
        self.maxSubmissions = maxSubmissions
        self.timeWindow = timeWindow
        self.storageKey = storageKey
    }
    
    /// Check if a submission is allowed for the given form ID
    /// - Parameter formId: The form ID to check
    /// - Returns: True if submission is allowed, false if rate limit exceeded
    public func canSubmit(formId: String) -> Bool {
        let key = "\(storageKey).\(formId)"
        let records = loadRecords(for: key)
        
        let now = Date()
        let cutoffTime = now.addingTimeInterval(-timeWindow)
        
        // Filter out old submissions
        let recentSubmissions = records.timestamps.filter { $0 > cutoffTime }
        
        return recentSubmissions.count < maxSubmissions
    }
    
    /// Record a submission for the given form ID
    /// - Parameter formId: The form ID to record
    public func recordSubmission(formId: String) {
        let key = "\(storageKey).\(formId)"
        var records = loadRecords(for: key)
        
        let now = Date()
        let cutoffTime = now.addingTimeInterval(-timeWindow)
        
        // Filter out old submissions and add new one
        var recentSubmissions = records.timestamps.filter { $0 > cutoffTime }
        recentSubmissions.append(now)
        
        records = SubmissionRecord(timestamps: recentSubmissions)
        saveRecords(records, for: key)
    }
    
    /// Get the number of remaining submissions allowed for the given form ID
    /// - Parameter formId: The form ID to check
    /// - Returns: Number of remaining submissions
    public func remainingSubmissions(formId: String) -> Int {
        let key = "\(storageKey).\(formId)"
        let records = loadRecords(for: key)
        
        let now = Date()
        let cutoffTime = now.addingTimeInterval(-timeWindow)
        
        let recentSubmissions = records.timestamps.filter { $0 > cutoffTime }
        let remaining = max(0, maxSubmissions - recentSubmissions.count)
        
        return remaining
    }
    
    /// Clear all submission records for a form (useful for testing)
    /// - Parameter formId: The form ID to clear
    public func clearRecords(formId: String) {
        let key = "\(storageKey).\(formId)"
        UserDefaults.standard.removeObject(forKey: key)
    }
    
    private func loadRecords(for key: String) -> SubmissionRecord {
        guard let data = UserDefaults.standard.data(forKey: key),
              let records = try? JSONDecoder().decode(SubmissionRecord.self, from: data) else {
            return SubmissionRecord(timestamps: [])
        }
        return records
    }
    
    private func saveRecords(_ records: SubmissionRecord, for key: String) {
        if let data = try? JSONEncoder().encode(records) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}
