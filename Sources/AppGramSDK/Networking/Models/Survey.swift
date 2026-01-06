import Foundation

/// Represents a survey that can be presented to users.
///
/// ## Discussion
/// Surveys contain multiple nodes (questions) that can be presented in sequence.
/// Each node can have different question types (yes/no, multiple choice, rating, etc.)
/// and can branch to different nodes based on answers.
///
/// ## Example
/// ```swift
/// let survey = try await getSurvey(slug: "nps")
/// ```
public struct Survey: Codable, Identifiable, Sendable {
    /// The unique identifier for the survey.
    public let id: String
    
    /// The display name of the survey.
    public let name: String
    
    /// The URL-friendly slug identifier.
    public let slug: String
    
    /// An optional description of the survey.
    public let description: String?
    
    /// The project ID this survey belongs to.
    public let projectId: String
    
    /// The list of question nodes in the survey.
    public let nodes: [SurveyNode]?
    
    /// Whether the survey is currently active.
    public let isActive: Bool
    
    /// The date when the survey was created.
    public let createdAt: Date?

    public init(
        id: String,
        name: String,
        slug: String,
        description: String?,
        projectId: String,
        nodes: [SurveyNode]?,
        isActive: Bool,
        createdAt: Date?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.projectId = projectId
        self.nodes = nodes
        self.isActive = isActive
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, nodes
        case projectId = "project_id"
        case isActive = "is_active"
        case createdAt = "created_at"
    }
}

/// Represents a single question node in a survey.
///
/// ## Discussion
/// Each survey node contains a question, its type, validation rules, and navigation
/// logic to determine the next node based on the answer.
///
/// ## Example
/// ```swift
/// let node = SurveyNode(
///     id: "node1",
///     question: "How satisfied are you?",
///     questionType: .rating,
///     options: nil,
///     minRating: 1,
///     maxRating: 5,
///     isRequired: true,
///     answerYesNodeId: nil,
///     answerNoNodeId: nil,
///     nextNodeId: "node2",
///     branches: nil,
///     resultMessage: nil,
///     order: 1
/// )
/// ```
public struct SurveyNode: Codable, Identifiable, Sendable {
    /// The unique identifier for the node.
    public let id: String
    
    /// The question text to display.
    public let question: String
    
    /// The type of question (yes/no, multiple choice, rating, etc.).
    public let questionType: QuestionType
    
    /// The available options for multiple choice or checkbox questions.
    public let options: [NodeOption]?
    
    /// The minimum rating value for rating questions.
    public let minRating: Int?
    
    /// The maximum rating value for rating questions.
    public let maxRating: Int?
    
    /// Whether this question must be answered.
    public let isRequired: Bool
    
    /// The next node ID if the answer is "yes" (for yes/no questions).
    public let answerYesNodeId: String?
    
    /// The next node ID if the answer is "no" (for yes/no questions).
    public let answerNoNodeId: String?
    
    /// The default next node ID to navigate to.
    public let nextNodeId: String?
    
    /// Conditional branches that determine the next node based on the answer.
    public let branches: [Branch]?
    
    /// A message to display when this node is reached (typically for end nodes).
    public let resultMessage: String?
    
    /// The display order of this node in the survey.
    public let order: Int?

    public init(
        id: String,
        question: String,
        questionType: QuestionType,
        options: [NodeOption]?,
        minRating: Int?,
        maxRating: Int?,
        isRequired: Bool,
        answerYesNodeId: String?,
        answerNoNodeId: String?,
        nextNodeId: String?,
        branches: [Branch]?,
        resultMessage: String?,
        order: Int?
    ) {
        self.id = id
        self.question = question
        self.questionType = questionType
        self.options = options
        self.minRating = minRating
        self.maxRating = maxRating
        self.isRequired = isRequired
        self.answerYesNodeId = answerYesNodeId
        self.answerNoNodeId = answerNoNodeId
        self.nextNodeId = nextNodeId
        self.branches = branches
        self.resultMessage = resultMessage
        self.order = order
    }

    enum CodingKeys: String, CodingKey {
        case id, question, options, branches
        case questionType = "question_type"
        case minRating = "min_rating"
        case maxRating = "max_rating"
        case isRequired = "is_required"
        case answerYesNodeId = "answer_yes_node_id"
        case answerNoNodeId = "answer_no_node_id"
        case nextNodeId = "next_node_id"
        case resultMessage = "result_message"
        case order = "sort_order"
    }
    
    // Custom decoder to handle is_required as integer (1/0) or boolean
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        question = try container.decode(String.self, forKey: .question)
        questionType = try container.decode(QuestionType.self, forKey: .questionType)
        options = try container.decodeIfPresent([NodeOption].self, forKey: .options)
        minRating = try container.decodeIfPresent(Int.self, forKey: .minRating)
        maxRating = try container.decodeIfPresent(Int.self, forKey: .maxRating)
        
        // Handle is_required as integer (1/0) or boolean
        if let boolValue = try? container.decode(Bool.self, forKey: .isRequired) {
            isRequired = boolValue
        } else if let intValue = try? container.decode(Int.self, forKey: .isRequired) {
            isRequired = intValue != 0
        } else {
            isRequired = false
        }
        
        answerYesNodeId = try container.decodeIfPresent(String.self, forKey: .answerYesNodeId)
        answerNoNodeId = try container.decodeIfPresent(String.self, forKey: .answerNoNodeId)
        nextNodeId = try container.decodeIfPresent(String.self, forKey: .nextNodeId)
        branches = try container.decodeIfPresent([Branch].self, forKey: .branches)
        resultMessage = try container.decodeIfPresent(String.self, forKey: .resultMessage)
        order = try container.decodeIfPresent(Int.self, forKey: .order)
    }
}

/// Types of questions that can be used in a survey.
///
/// ## Discussion
/// Defines the different question formats available for survey nodes.
///
/// ## Example
/// ```swift
/// let questionType: QuestionType = .rating
/// ```
public enum QuestionType: String, Codable, Sendable {
    /// A yes/no question.
    case yesNo = "yes_no"
    
    /// A short text answer question.
    case shortAnswer = "short_answer"
    
    /// A longer paragraph text answer question.
    case paragraph = "paragraph"
    
    /// A multiple choice question (single selection).
    case multipleChoice = "multiple_choice"
    
    /// A checkbox question (multiple selections).
    case checkboxes = "checkboxes"
    
    /// A rating question (numeric scale).
    case rating = "rating"

    public var displayName: String {
        switch self {
        case .yesNo:
            return "Yes/No"
        case .shortAnswer:
            return "Short Answer"
        case .paragraph:
            return "Paragraph"
        case .multipleChoice:
            return "Multiple Choice"
        case .checkboxes:
            return "Checkboxes"
        case .rating:
            return "Rating"
        }
    }
}

/// Represents an option for multiple choice or checkbox questions.
///
/// ## Discussion
/// Options are used in multiple choice and checkbox question types to provide
/// selectable choices to the user.
///
/// ## Example
/// ```swift
/// let option = NodeOption(
///     id: "opt1",
///     label: "Very Satisfied",
///     value: "5"
/// )
/// ```
public struct NodeOption: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the option.
    public let id: String
    
    /// The display label for the option.
    public let label: String
    
    /// The value associated with this option.
    public let value: String?

    public init(id: String, label: String, value: String?) {
        self.id = id
        self.label = label
        self.value = value
    }
    
    // Custom decoder to handle API responses that don't include 'id' field
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.label = try container.decode(String.self, forKey: .label)
        self.value = try container.decodeIfPresent(String.self, forKey: .value)
        
        // Try to decode id if present, otherwise generate from value or label
        if let id = try? container.decode(String.self, forKey: .id) {
            self.id = id
        } else {
            // Generate id from value if available, otherwise from label
            self.id = self.value ?? self.label
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case id, label, value
    }
}

/// Represents a conditional branch in a survey flow.
///
/// ## Discussion
/// Branches allow surveys to navigate to different nodes based on the answer
/// to a question. The condition determines when this branch should be taken.
///
/// ## Example
/// ```swift
/// let branch = Branch(
///     condition: BranchCondition(
///         type: .equals,
///         value: .int(5)
///     ),
///     nextNodeId: "node5"
/// )
/// ```
public struct Branch: Codable, Sendable {
    /// The condition that must be met for this branch to be taken.
    public let condition: BranchCondition
    
    /// The ID of the next node to navigate to if the condition is met.
    public let nextNodeId: String

    public init(condition: BranchCondition, nextNodeId: String) {
        self.condition = condition
        self.nextNodeId = nextNodeId
    }

    enum CodingKeys: String, CodingKey {
        case condition
        case nextNodeId = "next_node_id"
    }
}

/// Represents a condition for branching in a survey.
///
/// ## Discussion
/// Conditions are evaluated against the user's answer to determine which
/// branch to take in the survey flow.
///
/// ## Example
/// ```swift
/// let condition = BranchCondition(
///     type: .greaterThan,
///     value: .int(3)
/// )
/// ```
public struct BranchCondition: Codable, Sendable {
    /// The type of comparison to perform.
    public let type: ConditionType
    
    /// The value to compare against.
    public let value: AnyCodableValue

    public init(type: ConditionType, value: AnyCodableValue) {
        self.type = type
        self.value = value
    }
}

/// Types of conditions that can be used in survey branches.
///
/// ## Discussion
/// Defines the comparison operators available for conditional branching.
///
/// ## Example
/// ```swift
/// let conditionType: ConditionType = .equals
/// ```
public enum ConditionType: String, Codable, Sendable {
    /// Check if the answer equals the condition value.
    case equals = "equals"
    
    /// Check if the answer contains the condition value.
    case contains = "contains"
    
    /// Check if the answer is greater than the condition value.
    case greaterThan = "gt"
    
    /// Check if the answer is less than the condition value.
    case lessThan = "lt"
    
    /// Check if the answer is greater than or equal to the condition value.
    case greaterThanOrEqual = "gte"
    
    /// Check if the answer is less than or equal to the condition value.
    case lessThanOrEqual = "lte"
}

/// A type-erased codable value that can represent various types.
///
/// ## Discussion
/// Used in branch conditions to support different value types (string, number, boolean, array)
/// for comparison operations.
///
/// ## Example
/// ```swift
/// let value: AnyCodableValue = .int(5)
/// ```
public enum AnyCodableValue: Codable, Sendable, Equatable {
    /// A string value.
    case string(String)
    
    /// An integer value.
    case int(Int)
    
    /// A double value.
    case double(Double)
    
    /// A boolean value.
    case bool(Bool)
    
    /// An array of strings.
    case array([String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let value = try? container.decode(Bool.self) {
            self = .bool(value)
        } else if let value = try? container.decode(Int.self) {
            self = .int(value)
        } else if let value = try? container.decode(Double.self) {
            self = .double(value)
        } else if let value = try? container.decode(String.self) {
            self = .string(value)
        } else if let value = try? container.decode([String].self) {
            self = .array(value)
        } else {
            throw DecodingError.typeMismatch(
                AnyCodableValue.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Unsupported type")
            )
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .int(let value):
            try container.encode(value)
        case .double(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        }
    }

    public var stringValue: String? {
        if case .string(let value) = self { return value }
        return nil
    }

    public var intValue: Int? {
        if case .int(let value) = self { return value }
        return nil
    }

    public var boolValue: Bool? {
        if case .bool(let value) = self { return value }
        return nil
    }
}

/// Represents a user's answer to a survey question.
///
/// ## Discussion
/// Answers can be in different formats depending on the question type:
/// text for text questions, options for multiple choice, rating for rating questions,
/// and boolean for yes/no questions.
///
/// ## Example
/// ```swift
/// let answer: SurveyAnswer = .rating(5)
/// ```
public enum SurveyAnswer: Sendable, Equatable {
    /// A text answer (for short answer or paragraph questions).
    case text(String)
    
    /// Selected options (for multiple choice or checkbox questions).
    case options([String])
    
    /// A rating value (for rating questions).
    case rating(Int)
    
    /// A boolean answer (for yes/no questions).
    case boolean(Bool)

    public var isEmpty: Bool {
        switch self {
        case .text(let value):
            return value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .options(let values):
            return values.isEmpty
        case .rating:
            return false
        case .boolean:
            return false
        }
    }
}

/// A complete survey response containing all answers.
///
/// ## Discussion
/// This structure represents a full survey submission with all question answers,
/// user identification, and optional metadata.
///
/// ## Example
/// ```swift
/// let response = SurveyResponse(
///     answers: [answerPayload1, answerPayload2],
///     fingerprint: "device123",
///     externalUserId: "user456",
///     metadata: ["source": .string("app")]
/// )
/// ```
public struct SurveyResponse: Encodable, Sendable {
    /// The list of answers for each question node.
    public let answers: [SurveyAnswerPayload]
    
    /// The device fingerprint for anonymous users.
    public let fingerprint: String
    
    /// The external user ID, if available.
    public let externalUserId: String?
    
    /// Optional metadata to include with the response.
    public let metadata: [String: AnyCodableValue]?

    public init(
        answers: [SurveyAnswerPayload],
        fingerprint: String,
        externalUserId: String?,
        metadata: [String: AnyCodableValue]? = nil
    ) {
        self.answers = answers
        self.fingerprint = fingerprint
        self.externalUserId = externalUserId
        self.metadata = metadata
    }

    enum CodingKeys: String, CodingKey {
        case answers, fingerprint
        case externalUserId = "external_user_id"
        case metadata
    }
}

/// Represents a single answer to a survey question node.
///
/// ## Discussion
/// This structure encodes a single answer in the format expected by the API.
/// Different fields are used depending on the question type.
///
/// ## Example
/// ```swift
/// let payload = SurveyAnswerPayload(
///     nodeId: "node1",
///     answer: "5",
///     answerText: nil,
///     answerOptions: nil
/// )
/// ```
public struct SurveyAnswerPayload: Encodable, Sendable {
    /// The ID of the question node this answer is for.
    public let nodeId: String
    
    /// The answer value (for rating or yes/no questions).
    public let answer: String?
    
    /// The text answer (for text or paragraph questions).
    public let answerText: String?
    
    /// The selected options (for multiple choice or checkbox questions).
    public let answerOptions: [String]?

    public init(
        nodeId: String,
        answer: String? = nil,
        answerText: String? = nil,
        answerOptions: [String]? = nil
    ) {
        self.nodeId = nodeId
        self.answer = answer
        self.answerText = answerText
        self.answerOptions = answerOptions
    }

    enum CodingKeys: String, CodingKey {
        case nodeId = "node_id"
        case answer
        case answerText = "answer_text"
        case answerOptions = "answer_options"
    }
}
