import Foundation

/// Represents a collection of help articles.
///
/// ## Discussion
/// Help collections organize related help articles together, making it easier for
/// users to find relevant documentation.
///
/// ## Example
/// ```swift
/// let collection = HelpCollection(
///     id: "col123",
///     name: "Getting Started",
///     slug: "getting-started",
///     description: "Learn the basics",
///     icon: "book",
///     projectId: "project456",
///     articles: [],
///     order: 1,
///     createdAt: Date()
/// )
/// ```
public struct HelpCollection: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the collection.
    public let id: String
    
    /// The display name of the collection.
    public let name: String
    
    /// The URL-friendly slug identifier.
    public let slug: String
    
    /// An optional description of the collection.
    public let description: String?
    
    /// An optional icon identifier for the collection.
    public let icon: String?
    
    /// The project ID this collection belongs to.
    public let projectId: String
    
    /// The list of articles in this collection.
    public let articles: [HelpArticle]?
    
    /// The display order of this collection.
    public let order: Int?
    
    /// The date when the collection was created.
    public let createdAt: Date?

    public init(
        id: String,
        name: String,
        slug: String,
        description: String?,
        icon: String?,
        projectId: String,
        articles: [HelpArticle]?,
        order: Int?,
        createdAt: Date?
    ) {
        self.id = id
        self.name = name
        self.slug = slug
        self.description = description
        self.icon = icon
        self.projectId = projectId
        self.articles = articles
        self.order = order
        self.createdAt = createdAt
    }

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, icon, articles, order
        case projectId = "project_id"
        case createdAt = "created_at"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: HelpCollection, rhs: HelpCollection) -> Bool {
        lhs.id == rhs.id
    }
}

/// Represents a help article or documentation page.
///
/// ## Discussion
/// Help articles contain documentation content that can be displayed to users.
/// Articles can be organized into collections and may include markdown or HTML content.
///
/// ## Example
/// ```swift
/// let article = HelpArticle(
///     id: "article123",
///     title: "How to Get Started",
///     slug: "how-to-get-started",
///     content: "# Getting Started\n\nWelcome to...",
///     excerpt: "Learn the basics",
///     collectionId: "col456",
///     projectId: "project789",
///     order: 1,
///     isPublished: true,
///     createdAt: Date(),
///     updatedAt: nil
/// )
/// ```
public struct HelpArticle: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the article.
    public let id: String
    
    /// The title of the article.
    public let title: String
    
    /// The URL-friendly slug identifier.
    public let slug: String
    
    /// The full content of the article (may contain markdown or HTML).
    public let content: String
    
    /// An optional excerpt or summary of the article.
    public let excerpt: String?
    
    /// The ID of the collection this article belongs to.
    public let collectionId: String?
    
    /// The project ID this article belongs to.
    public let projectId: String?
    
    /// The display order of this article.
    public let order: Int?
    
    /// Whether the article is published and visible to users.
    public let isPublished: Bool
    
    /// The date when the article was created.
    public let createdAt: Date?
    
    /// The date when the article was last updated.
    public let updatedAt: Date?

    public init(
        id: String,
        title: String,
        slug: String,
        content: String,
        excerpt: String?,
        collectionId: String?,
        projectId: String?,
        order: Int?,
        isPublished: Bool,
        createdAt: Date?,
        updatedAt: Date?
    ) {
        self.id = id
        self.title = title
        self.slug = slug
        self.content = content
        self.excerpt = excerpt
        self.collectionId = collectionId
        self.projectId = projectId
        self.order = order
        self.isPublished = isPublished
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, slug, content, excerpt, order
        case collectionId = "collection_id"
        case projectId = "project_id"
        case isPublished = "is_published"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // Custom decoder to handle is_published as integer (1/0) or boolean
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        slug = try container.decode(String.self, forKey: .slug)
        content = try container.decode(String.self, forKey: .content)
        excerpt = try container.decodeIfPresent(String.self, forKey: .excerpt)
        collectionId = try container.decodeIfPresent(String.self, forKey: .collectionId)
        projectId = try container.decodeIfPresent(String.self, forKey: .projectId)
        order = try container.decodeIfPresent(Int.self, forKey: .order)
        createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Date.self, forKey: .updatedAt)
        
        // Handle is_published as integer (1/0) or boolean
        if let boolValue = try? container.decode(Bool.self, forKey: .isPublished) {
            isPublished = boolValue
        } else if let intValue = try? container.decode(Int.self, forKey: .isPublished) {
            isPublished = intValue != 0
        } else {
            isPublished = false
        }
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: HelpArticle, rhs: HelpArticle) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Public Help Collection (API Response)

/// A public help collection as returned by the API.
///
/// ## Discussion
/// This structure represents the API response format for help collections,
/// which may include additional metadata like flows and version information.
public struct PublicHelpCollection: Codable, Sendable {
    /// The unique identifier for the collection.
    public let id: String
    
    /// The display name of the collection.
    public let name: String
    
    /// An optional description of the collection.
    public let description: String?
    
    /// The project ID this collection belongs to.
    public let projectId: String
    
    /// Whether the collection is live and visible.
    public let isLive: Bool
    
    /// An optional version identifier.
    public let version: String?
    
    /// The help flows in this collection.
    public let flows: [HelpFlow]
    
    /// The date when the collection was created.
    public let createdAt: Date?
    
    /// The date when the collection was last updated.
    public let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, description, flows, version
        case projectId = "project_id"
        case isLive = "is_live"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

// MARK: - Help Flow

/// Represents a help flow that guides users through a series of steps or decisions.
///
/// ## Discussion
/// Help flows can contain articles, decision nodes, or wizard steps to create
/// interactive help experiences.
public struct HelpFlow: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the flow.
    public let id: String
    
    /// The display name of the flow.
    public let name: String
    
    /// The URL-friendly slug identifier.
    public let slug: String
    
    /// An optional description of the flow.
    public let description: String?
    
    /// An optional icon identifier.
    public let icon: String?
    
    /// An optional color code.
    public let color: String?
    
    /// The display type for the flow.
    public let displayType: String?
    
    /// The ID of the collection this flow belongs to.
    public let collectionId: String?
    
    /// The articles in this flow.
    public let articles: [HelpArticle]?
    
    /// The decision nodes in this flow.
    public let decisionNodes: [HelpDecisionNode]?
    
    /// The wizard steps in this flow.
    public let wizardSteps: [HelpWizardStep]?
    
    /// The sort order of this flow.
    public let sortOrder: Int?
    
    /// The date when the flow was created.
    public let createdAt: Date?
    
    /// The date when the flow was last updated.
    public let updatedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, description, icon, color, articles
        case displayType = "display_type"
        case collectionId = "collection_id"
        case decisionNodes = "decision_nodes"
        case wizardSteps = "wizard_steps"
        case sortOrder = "sort_order"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: HelpFlow, rhs: HelpFlow) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Help Decision Node

/// Represents a decision node in a help flow.
///
/// ## Discussion
/// Decision nodes allow users to make choices that guide them through different
/// paths in a help flow. Each node represents a question with Yes/No answers
/// that navigate to different nodes or display articles at leaf nodes.
///
/// ## Example
/// ```swift
/// let node = HelpDecisionNode(
///     id: "node1",
///     flowId: "flow123",
///     parentId: nil,  // Root node
///     question: "Are you having login issues?",
///     answerYesNodeId: "node2",
///     answerNoNodeId: "node3",
///     articleId: nil
/// )
/// ```
public struct HelpDecisionNode: Codable, Identifiable, Sendable {
    /// The unique identifier for the decision node.
    public let id: String
    
    /// The ID of the flow this node belongs to.
    public let flowId: String
    
    /// The ID of the parent node. `nil` indicates this is the root node.
    public let parentId: String?
    
    /// The question text to display to the user.
    public let question: String
    
    /// The next node ID if the user answers "Yes".
    public let answerYesNodeId: String?
    
    /// The next node ID if the user answers "No".
    public let answerNoNodeId: String?
    
    /// The article ID to show at leaf nodes (when there are no more questions).
    public let articleId: String?

    public init(
        id: String,
        flowId: String,
        parentId: String?,
        question: String,
        answerYesNodeId: String?,
        answerNoNodeId: String?,
        articleId: String?
    ) {
        self.id = id
        self.flowId = flowId
        self.parentId = parentId
        self.question = question
        self.answerYesNodeId = answerYesNodeId
        self.answerNoNodeId = answerNoNodeId
        self.articleId = articleId
    }

    enum CodingKeys: String, CodingKey {
        case id
        case flowId = "flow_id"
        case parentId = "parent_id"
        case question
        case answerYesNodeId = "answer_yes_node_id"
        case answerNoNodeId = "answer_no_node_id"
        case articleId = "article_id"
    }
}

// MARK: - Help Wizard Step

/// Represents a step in a help wizard flow.
///
/// ## Discussion
/// Wizard steps are part of a multi-step help flow that guides users through
/// a process or tutorial. Steps are displayed sequentially and can optionally
/// link to help articles for additional context.
///
/// ## Example
/// ```swift
/// let step = HelpWizardStep(
///     id: "step123",
///     stepNumber: 1,
///     title: "Getting Started",
///     content: "<p>Welcome to the first step...</p>",
///     articleId: "article456",
///     flowId: "flow789",
///     createdAt: Date(),
///     updatedAt: nil
/// )
/// ```
public struct HelpWizardStep: Codable, Identifiable, Sendable, Hashable {
    /// The unique identifier for the wizard step.
    public let id: String

    /// The step number used for ordering (ascending).
    public let stepNumber: Int

    /// The title of the wizard step.
    public let title: String

    /// The HTML or markdown content for the step.
    public let content: String

    /// Optional ID of a linked help article.
    public let articleId: String?

    /// The ID of the flow this step belongs to.
    public let flowId: String?

    /// The date when the step was created.
    public let createdAt: Date?

    /// The date when the step was last updated.
    public let updatedAt: Date?

    public init(
        id: String,
        stepNumber: Int,
        title: String,
        content: String,
        articleId: String? = nil,
        flowId: String? = nil,
        createdAt: Date? = nil,
        updatedAt: Date? = nil
    ) {
        self.id = id
        self.stepNumber = stepNumber
        self.title = title
        self.content = content
        self.articleId = articleId
        self.flowId = flowId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, content
        case stepNumber = "step_number"
        case articleId = "article_id"
        case flowId = "flow_id"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    public static func == (lhs: HelpWizardStep, rhs: HelpWizardStep) -> Bool {
        lhs.id == rhs.id
    }
}
