import Foundation

internal actor APIClient {
    private let baseURL: String
    private let projectId: String
    private let apiKey: String?
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    public init(baseURL: String, projectId: String, apiKey: String? = nil) {
        // Mask API key for logging
        let maskedApiKey: String
        if let apiKey = apiKey, apiKey.count > 12 {
            let start = String(apiKey.prefix(8))
            let end = String(apiKey.suffix(4))
            maskedApiKey = "\(start)****\(end)"
        } else if let apiKey = apiKey {
            maskedApiKey = String(repeating: "*", count: min(apiKey.count, 12))
        } else {
            maskedApiKey = "nil"
        }
        
        logDebug("""
        🔧 APIClient Initialization:
           Base URL: \(baseURL)
           Project ID: \(projectId.isEmpty ? "(empty)" : projectId)
           API Key: \(maskedApiKey) \(apiKey != nil ? "(provided)" : "(not provided)")
        """)
        
        self.baseURL = baseURL
        self.projectId = projectId
        self.apiKey = apiKey
        self.session = URLSession.shared

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // Try ISO8601 first (handles most standard formats)
            if let date = ISO8601DateFormatter().date(from: dateString) {
                return date
            }
            
            // Try with microseconds (6 digits) - e.g., "2025-12-26T13:31:10.142568Z"
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSSZ"
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Try with milliseconds (3 digits) - e.g., "2025-12-26T13:31:10.142Z"
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            // Try without fractional seconds - e.g., "2025-12-26T13:31:10Z"
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "Cannot decode date string \(dateString)"
            )
        }
        self.decoder = decoder

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        self.encoder = encoder
    }

    public func get<T: Decodable>(
        endpoint: Endpoints,
        filters: WishFilters? = nil,
        wishId: String? = nil,
        supportRequestFilters: SupportRequestFilters? = nil,
        blogFilters: BlogFilters? = nil,
        token: String? = nil
    ) async throws -> T {
        logDebug("GET request to endpoint: \(endpoint.path), filters: \(String(describing: filters)), wishId: \(String(describing: wishId)), supportRequestFilters: \(String(describing: supportRequestFilters)), blogFilters: \(String(describing: blogFilters))")
        let request = try buildRequest(
            endpoint: endpoint,
            method: .get,
            filters: filters,
            wishId: wishId,
            supportRequestFilters: supportRequestFilters,
            blogFilters: blogFilters,
            token: token
        )
        return try await execute(request)
    }

    public func post<T: Decodable, Body: Encodable>(
        endpoint: Endpoints,
        body: Body
    ) async throws -> T {
        logDebug("POST request to endpoint: \(endpoint.path) with body type: \(type(of: body))")
        var request = try buildRequest(endpoint: endpoint, method: .post)
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        return try await execute(request)
    }

    public func post<Body: Encodable>(
        endpoint: Endpoints,
        body: Body
    ) async throws {
        logDebug("POST request (no response) to endpoint: \(endpoint.path) with body type: \(type(of: body))")
        var request = try buildRequest(endpoint: endpoint, method: .post)
        request.httpBody = try encoder.encode(body)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        let _: EmptyResponse = try await execute(request)
    }

    public func delete(endpoint: Endpoints) async throws {
        logDebug("DELETE request to endpoint: \(endpoint.path)")
        let request = try buildRequest(endpoint: endpoint, method: .delete)
        let _: EmptyResponse = try await execute(request)
    }

    public func uploadFile(
        _ data: Data,
        fileName: String,
        mimeType: String
    ) async throws -> FileUploadResponse {
        logInfo("Uploading file: \(fileName), size: \(data.count) bytes, mimeType: \(mimeType)")
        guard var components = URLComponents(string: baseURL + Endpoints.uploadFile.path) else {
            logError("Failed to create URL components for file upload")
            throw AppGramError.invalidResponse
        }
        components.queryItems = [URLQueryItem(name: "project_id", value: projectId)]

        guard let url = components.url else {
            throw AppGramError.invalidResponse
        }

        let boundary = UUID().uuidString
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // Add API key to X-API-Key header if provided
        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
        }

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        return try await execute(request)
    }

    private func buildRequest(
        endpoint: Endpoints,
        method: HTTPMethod,
        filters: WishFilters? = nil,
        wishId: String? = nil,
        supportRequestFilters: SupportRequestFilters? = nil,
        blogFilters: BlogFilters? = nil,
        token: String? = nil
    ) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL + endpoint.path) else {
            logError("Failed to create URL components for endpoint: \(endpoint.path)")
            throw AppGramError.invalidResponse
        }

        let queryItems = endpoint.queryItems(projectId: projectId, filters: filters, wishId: wishId, supportRequestFilters: supportRequestFilters, blogFilters: blogFilters, token: token)
        if !queryItems.isEmpty {
            components.queryItems = queryItems
        }

        guard let url = components.url else {
            logError("Failed to create URL from components")
            throw AppGramError.invalidResponse
        }

        logDebug("Building \(method.rawValue) request for URL: \(url.absoluteString)")
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        // Add API key to X-API-Key header if provided
        if let apiKey = apiKey {
            request.setValue(apiKey, forHTTPHeaderField: "X-API-Key")
            logDebug("Added X-API-Key header to request for endpoint: \(endpoint.path)")
        } else {
            logDebug("No API key provided, request will be made without X-API-Key header")
        }
        
        return request
    }

    private func execute<T: Decodable>(_ request: URLRequest) async throws -> T {
        logDebug("Executing request to: \(request.url?.absoluteString ?? "unknown")")

        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            logError("Invalid HTTP response received")
            throw AppGramError.invalidResponse
        }

        logDebug("Received HTTP \(httpResponse.statusCode) from \(request.url?.absoluteString ?? "unknown")")

        switch httpResponse.statusCode {
        case 200...299:
            do {
                let decoded = try decoder.decode(T.self, from: data)
                logDebug("Successfully decoded response of type \(T.self)")
                return decoded
            } catch {
                let requestId = UUID().uuidString.prefix(8)
                logDecodingError(error, requestId: String(requestId), expectedType: T.self, data: data, statusCode: httpResponse.statusCode, url: request.url?.absoluteString ?? "unknown")
                throw AppGramError.decodingError(error.localizedDescription)
            }
        case 401:
            logError("Unauthorized request to \(request.url?.absoluteString ?? "unknown")")
            throw AppGramError.unauthorized
        case 403:
            logError("Forbidden request to \(request.url?.absoluteString ?? "unknown")")
            throw AppGramError.forbidden
        case 404:
            logError("Resource not found at \(request.url?.absoluteString ?? "unknown")")
            throw AppGramError.notFound
        case 400...499:
            if let errorResponse = try? decoder.decode(APIErrorResponse.self, from: data) {
                logError("Validation error: \(errorResponse.message)")
                throw AppGramError.validationError(errorResponse.message)
            }
            logError("Client error with status code \(httpResponse.statusCode)")
            throw AppGramError.validationError("Request failed")
        case 500...599:
            logError("Server error with status code \(httpResponse.statusCode)")
            throw AppGramError.serverError(httpResponse.statusCode)
        default:
            logError("Unexpected status code: \(httpResponse.statusCode)")
            throw AppGramError.invalidResponse
        }
    }
    
    // MARK: - Decoding Error Logging
    
    private func logDecodingError<T>(
        _ error: Error,
        requestId: String,
        expectedType: T.Type,
        data: Data,
        statusCode: Int,
        url: String
    ) {
        logError("❌ ================================")
        logError("❌ DECODING ERROR DETAILS [\(requestId)]")
        logError("❌ ================================")
        logError("❌ Expected Type: \(String(describing: expectedType))")
        logError("❌ Status Code: \(statusCode)")
        logError("❌ URL: \(url)")
        logError("❌ Data Size: \(data.count) bytes")
        
        // Handle DecodingError specifically for detailed information
        if let decodingError = error as? DecodingError {
            switch decodingError {
            case .typeMismatch(let type, let context):
                logError("❌ TYPE MISMATCH ERROR:")
                logInfo("   Expected: \(type)")
                logInfo("   Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                logInfo("   Description: \(context.debugDescription)")
                if let underlyingError = context.underlyingError {
                    logInfo("   Underlying Error: \(underlyingError)")
                }
                // Show detailed context around the problematic field
                showJSONContext(data: data, codingPath: context.codingPath, errorType: "TYPE_MISMATCH")
                
            case .valueNotFound(let type, let context):
                logError("❌ VALUE NOT FOUND ERROR:")
                logInfo("   Missing Type: \(type)")
                logInfo("   Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                logInfo("   Description: \(context.debugDescription)")
                if let underlyingError = context.underlyingError {
                    logInfo("   Underlying Error: \(underlyingError)")
                }
                // Show detailed context around the problematic field
                showJSONContext(data: data, codingPath: context.codingPath, errorType: "VALUE_NOT_FOUND")
                
            case .keyNotFound(let key, let context):
                logError("❌ KEY NOT FOUND ERROR:")
                logInfo("   Missing Key: '\(key.stringValue)'")
                logInfo("   Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                logInfo("   Description: \(context.debugDescription)")
                if let underlyingError = context.underlyingError {
                    logInfo("   Underlying Error: \(underlyingError)")
                }
                // Show detailed context around the problematic field
                showJSONContext(data: data, codingPath: context.codingPath, errorType: "KEY_NOT_FOUND", missingKey: key.stringValue)
                
            case .dataCorrupted(let context):
                logError("❌ DATA CORRUPTED ERROR:")
                logInfo("   Coding Path: \(context.codingPath.map { $0.stringValue }.joined(separator: " -> "))")
                logInfo("   Description: \(context.debugDescription)")
                if let underlyingError = context.underlyingError {
                    logInfo("   Underlying Error: \(underlyingError)")
                }
                // Show detailed context around the problematic field
                showJSONContext(data: data, codingPath: context.codingPath, errorType: "DATA_CORRUPTED")
                
            @unknown default:
                logError("❌ UNKNOWN DECODING ERROR:")
                logError("   Error: \(decodingError)")
            }
        } else {
            // Handle other types of errors
            logError("❌ NON-DECODING ERROR:")
            logError("   Error Type: \(type(of: error))")
            logError("   Error: \(error)")
            logError("   Localized Description: \(error.localizedDescription)")
        }
        
        // Always show the raw response data for debugging
        logError("❌ Raw Response Data:")
        if let responseString = String(data: data, encoding: .utf8) {
            // Limit output for very large responses
            if responseString.count > 2000 {
                let truncated = String(responseString.prefix(2000))
                logError("   \(truncated)... [TRUNCATED - Total length: \(responseString.count) characters]")
            } else {
                logError("   \(responseString)")
            }
        } else {
            logError("   [Unable to decode as UTF-8]")
            let hexString = data.prefix(100).map { String(format: "%02x", $0) }.joined(separator: " ")
            logError("   Raw bytes (first 100): \(hexString)")
        }
        
        logError("❌ ================================")
    }
    
    private func showJSONContext(data: Data, codingPath: [CodingKey], errorType: String, missingKey: String? = nil) {
        logInfo("🔍 JSON CONTEXT ANALYSIS:")
        
        do {
            guard let jsonObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] else {
                logInfo("   ❌ Unable to parse JSON as dictionary")
                return
            }
            
            // Navigate to the problematic location
            var current: Any = jsonObject
            var navigationPath: [String] = []
            
            // Navigate through the coding path
            for (index, key) in codingPath.enumerated() {
                navigationPath.append(key.stringValue)
                
                if let dict = current as? [String: Any] {
                    if let value = dict[key.stringValue] {
                        current = value
                        logInfo("   ✅ Found '\(key.stringValue)' at path: \(navigationPath.joined(separator: " -> "))")
                    } else {
                        logInfo("   ❌ Key '\(key.stringValue)' not found at path: \(navigationPath.joined(separator: " -> "))")
                        let availableKeys = dict.keys.sorted().joined(separator: ", ")
                        logInfo("   📋 Available keys at this level: [\(availableKeys)]")
                        break
                    }
                } else if let array = current as? [Any] {
                    if let intKey = Int(key.stringValue), intKey < array.count {
                        current = array[intKey]
                        logInfo("   ✅ Found array index '\(key.stringValue)' at path: \(navigationPath.joined(separator: " -> "))")
                    } else {
                        logInfo("   ❌ Array index '\(key.stringValue)' out of bounds at path: \(navigationPath.joined(separator: " -> "))")
                        logInfo("   📋 Array length: \(array.count)")
                        break
                    }
                } else {
                    logInfo("   ❌ Cannot navigate further - current value is not a dictionary or array")
                    logInfo("   📋 Current value type: \(type(of: current))")
                    logInfo("   📋 Current value: \(String(describing: current))")
                    break
                }
            }
            
            // Show the problematic field details
            logInfo("   📍 PROBLEMATIC FIELD ANALYSIS:")
            logInfo("   📍 Full Path: \(navigationPath.joined(separator: " -> "))")
            logInfo("   📍 Actual Value: \(String(describing: current))")
            logInfo("   📍 Actual Type: \(type(of: current))")
            
            // Show the parent context
            if codingPath.count > 0 {
                showParentContext(jsonObject: jsonObject, codingPath: Array(codingPath.dropLast()), missingKey: missingKey)
            }
            
        } catch {
            logInfo("   ❌ Failed to parse JSON: \(error)")
            if let preview = String(data: data.prefix(500), encoding: .utf8) {
                logInfo("   📋 Raw data (first 500 chars): \(preview)")
            } else {
                logInfo("   📋 Raw data (first 500 chars): [Unable to decode]")
            }
        }
    }
    
    private func showParentContext(jsonObject: [String: Any], codingPath: [CodingKey], missingKey: String?) {
        var current: Any = jsonObject
        
        // Navigate to parent
        for key in codingPath {
            if let dict = current as? [String: Any] {
                current = dict[key.stringValue] ?? [:]
            } else if let array = current as? [Any], let intKey = Int(key.stringValue), intKey < array.count {
                current = array[intKey]
            }
        }
        
        logInfo("   🔎 PARENT OBJECT CONTEXT:")
        if let parentDict = current as? [String: Any] {
            let sortedKeys = parentDict.keys.sorted()
            logInfo("   🔎 Available fields in parent object:")
            
            for key in sortedKeys {
                let value = parentDict[key]
                let valueType = type(of: value)
                let preview = getValuePreview(value)
                
                if let missingKey = missingKey, key == missingKey {
                    logInfo("   🔎   ❌ MISSING -> '\(key)': Expected but not found")
                } else {
                    logInfo("   🔎   ✅ '\(key)': \(valueType) = \(preview)")
                }
            }
            
            // Suggest possible field name matches if key is missing
            if let missingKey = missingKey {
                let similarKeys = findSimilarKeys(target: missingKey, available: sortedKeys)
                if !similarKeys.isEmpty {
                    logInfo("   💡 Similar field names found: \(similarKeys.joined(separator: ", "))")
                }
            }
            
        } else if let parentArray = current as? [Any] {
            logInfo("   🔎 Parent is an array with \(parentArray.count) elements")
            for (index, item) in parentArray.enumerated() {
                if index < 5 { // Limit to first 5 items
                    logInfo("   🔎   [\(index)]: \(type(of: item)) = \(getValuePreview(item))")
                } else {
                    logInfo("   🔎   ... and \(parentArray.count - 5) more items")
                    break
                }
            }
        } else {
            logInfo("   🔎 Parent value: \(type(of: current)) = \(getValuePreview(current))")
        }
    }
    
    private func getValuePreview(_ value: Any?) -> String {
        guard let value = value else { return "nil" }
        
        if let string = value as? String {
            return string.count > 50 ? "\"\(String(string.prefix(50)))...\"" : "\"\(string)\""
        } else if let number = value as? NSNumber {
            return "\(number)"
        } else if let bool = value as? Bool {
            return "\(bool)"
        } else if let array = value as? [Any] {
            return "Array[\(array.count) items]"
        } else if let dict = value as? [String: Any] {
            return "Object{\(dict.keys.count) fields}"
        } else {
            return "\(String(describing: value))"
        }
    }
    
    private func findSimilarKeys(target: String, available: [String]) -> [String] {
        let targetLower = target.lowercased()
        return available.filter { key in
            let keyLower = key.lowercased()
            // Check for exact match, contains, or Levenshtein distance
            return keyLower.contains(targetLower) ||
                   targetLower.contains(keyLower) ||
                   levenshteinDistance(targetLower, keyLower) <= 2
        }
    }
    
    private func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let str1Array = Array(str1)
        let str2Array = Array(str2)
        let str1Count = str1Array.count
        let str2Count = str2Array.count
        
        if str1Count == 0 { return str2Count }
        if str2Count == 0 { return str1Count }
        
        var matrix = Array(repeating: Array(repeating: 0, count: str2Count + 1), count: str1Count + 1)
        
        for i in 0...str1Count { matrix[i][0] = i }
        for j in 0...str2Count { matrix[0][j] = j }
        
        for i in 1...str1Count {
            for j in 1...str2Count {
                let cost = str1Array[i-1] == str2Array[j-1] ? 0 : 1
                matrix[i][j] = min(
                    matrix[i-1][j] + 1,      // deletion
                    matrix[i][j-1] + 1,      // insertion
                    matrix[i-1][j-1] + cost  // substitution
                )
            }
        }
        
        return matrix[str1Count][str2Count]
    }
}

struct EmptyResponse: Decodable {}

struct APIErrorResponse: Decodable {
    let message: String
    let error: String?
}

// Generic API response wrapper for single items
internal struct APIResponse<T: Decodable>: Decodable {
    public let success: Bool?
    public let data: T

    enum CodingKeys: String, CodingKey {
        case success, data
    }
}

// Generic API response wrapper for optional data (when API can return null)
internal struct OptionalAPIResponse<T: Decodable>: Decodable {
    public let success: Bool?
    public let data: T?

    enum CodingKeys: String, CodingKey {
        case success, data
    }
}

// Generic API response wrapper for paginated lists
internal struct PaginatedAPIResponse<T: Decodable>: Decodable {
    public let success: Bool?
    public let data: [T]
    public let total: Int?
    public let page: Int?
    public let perPage: Int?
    public let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case success, data, total, page
        case perPage = "per_page"
        case totalPages = "total_pages"
    }
}

internal struct WishesResponse: Decodable {
    public let success: Bool?
    public let data: [Wish]
    public let total: Int?
    public let page: Int?
    public let perPage: Int?
    public let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case success, data, total, page
        case perPage = "per_page"
        case totalPages = "total_pages"
    }
    
    // Computed property for backward compatibility
    public var wishes: [Wish] {
        return data
    }
    
    // Computed property for backward compatibility
    public var limit: Int? {
        return perPage
    }
}

internal struct CommentsResponse: Decodable {
    public let success: Bool?
    public let data: [Comment]
    
    enum CodingKeys: String, CodingKey {
        case success, data
    }
    
    // Computed property for backward compatibility
    public var comments: [Comment] {
        return data
    }
}

internal struct CategoriesResponse: Decodable {
    public let success: Bool?
    public let data: [Category]
    
    enum CodingKeys: String, CodingKey {
        case success, data
    }
    
    // Computed property for backward compatibility
    public var categories: [Category] {
        return data
    }
}

// Roadmap API Response Structure
internal struct RoadmapAPIResponse: Decodable {
    public let success: Bool?
    public let data: RoadmapData
    
    enum CodingKeys: String, CodingKey {
        case success, data
    }
}

internal struct RoadmapData: Decodable {
    public let roadmap: RoadmapConfig?
    public let wishes: [Wish]
    public let categories: [Category]?
    
    enum CodingKeys: String, CodingKey {
        case roadmap, wishes, categories
    }
}

internal struct RoadmapConfig: Decodable {
    public let id: String
    public let name: String
    public let description: String?
    public let visibility: String?
    public let showVoteCounts: Bool?
    public let showComments: Bool?
    public let columns: [RoadmapColumnConfig]
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, visibility, columns
        case showVoteCounts = "show_vote_counts"
        case showComments = "show_comments"
    }
}

internal struct RoadmapColumnConfig: Decodable {
    public let id: String
    public let name: String
    public let color: String?
    public let sortOrder: Int?
    public let wipLimit: Int?
    public let items: [RoadmapColumnItem]
    
    enum CodingKeys: String, CodingKey {
        case id, name, color, items
        case sortOrder = "sort_order"
        case wipLimit = "wip_limit"
    }
}

internal struct RoadmapColumnItem: Decodable {
    public let id: String
    public let title: String
    public let description: String?
    public let color: String?
    public let targetDate: String?
    public let sortOrder: Int?
    public let wish: RoadmapWish?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, color, wish
        case targetDate = "target_date"
        case sortOrder = "sort_order"
    }
}

// Simplified Wish model for roadmap column items (has different structure than full Wish)
internal struct RoadmapWish: Decodable {
    public let id: String
    public let title: String
    public let description: String?
    public let status: WishStatus
    public let voteCount: Int
    public let commentCount: Int
    public let authorName: String?
    public let authorEmail: String?
    public let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, status
        case voteCount = "vote_count"
        case commentCount = "comment_count"
        case authorEmail = "author_email"
        case createdAt = "created_at"
        case author
    }
    
    // Custom decoder to handle author object structure
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decodeIfPresent(String.self, forKey: .description)
        status = try container.decode(WishStatus.self, forKey: .status)
        voteCount = try container.decode(Int.self, forKey: .voteCount)
        commentCount = try container.decode(Int.self, forKey: .commentCount)
        
        // Try to get authorEmail from direct field first, then from author object
        if let email = try? container.decodeIfPresent(String.self, forKey: .authorEmail) {
            authorEmail = email
        } else if let authorContainer = try? container.nestedContainer(keyedBy: AuthorKeys.self, forKey: .author),
                  let email = try? authorContainer.decodeIfPresent(String.self, forKey: .email) {
            authorEmail = email
        } else {
            authorEmail = nil
        }
        
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        
        // Handle author object - get full_name from nested author object
        if let authorContainer = try? container.nestedContainer(keyedBy: AuthorKeys.self, forKey: .author) {
            authorName = try authorContainer.decodeIfPresent(String.self, forKey: .fullName)
        } else {
            authorName = nil
        }
    }
    
    private enum AuthorKeys: String, CodingKey {
        case fullName = "full_name"
        case email
    }
}

// Backward compatibility wrapper
internal struct RoadmapResponse: Decodable {
    public let success: Bool?
    public let data: [RoadmapItem]
    
    enum CodingKeys: String, CodingKey {
        case success, data
    }
    
    // Computed property for backward compatibility
    public var items: [RoadmapItem] {
        return data
    }
    
    // Initialize from RoadmapAPIResponse
    public init(from apiResponse: RoadmapAPIResponse) {
        self.success = apiResponse.success
        // Extract roadmap items from wishes array
        // Convert Wish objects to RoadmapItem objects
        self.data = apiResponse.data.wishes.map { wish in
            RoadmapItem(
                id: wish.id,
                title: wish.title,
                description: wish.description,
                status: wish.status,
                voteCount: wish.voteCount,
                commentCount: wish.commentCount,
                category: wish.category,
                targetDate: nil, // Will be set from roadmap column items if available
                completedAt: nil,
                createdAt: wish.createdAt
            )
        }
    }
}

internal struct SupportTicketsResponse: Decodable {
    public let success: Bool?
    public let data: [SupportTicket]
    public let total: Int?
    public let page: Int?
    public let perPage: Int?
    public let totalPages: Int?
    
    enum CodingKeys: String, CodingKey {
        case success, data, total, page
        case perPage = "per_page"
        case totalPages = "total_pages"
    }
    
    // Computed property for backward compatibility
    public var tickets: [SupportTicket] {
        return data
    }
}

internal struct SupportMessagesResponse: Decodable {
    public let success: Bool?
    public let data: [SupportMessage]
    
    enum CodingKeys: String, CodingKey {
        case success, data
    }
    
    // Computed property for backward compatibility
    public var messages: [SupportMessage] {
        return data
    }
}

internal struct FileUploadResponse: Decodable {
    public let url: String
    public let fileName: String?

    enum CodingKeys: String, CodingKey {
        case url
        case fileName = "file_name"
    }
}

internal struct HelpCollectionsResponse: Decodable {
    public let success: Bool?
    public let data: PublicHelpCollection
    
    enum CodingKeys: String, CodingKey {
        case success, data
    }
    
    // Computed property to convert flows to HelpCollection format for UI compatibility
    public var collections: [HelpCollection] {
        return data.flows.map { flow in
            HelpCollection(
                id: flow.id,
                name: flow.name,
                slug: flow.slug,
                description: flow.description,
                icon: flow.icon,
                projectId: data.projectId,
                articles: flow.articles,
                order: flow.sortOrder,
                createdAt: flow.createdAt
            )
        }
    }
}

internal struct HelpArticlesResponse: Decodable {
    public let success: Bool?
    public let data: [HelpArticle]
    
    enum CodingKeys: String, CodingKey {
        case success, data
    }
    
    // Computed property for backward compatibility
    public var articles: [HelpArticle] {
        return data
    }
}
