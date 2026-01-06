import Foundation

internal enum Endpoints {
    // Feedback
    case wishes(projectId: String)
    case createWish
    case wish(id: String)
    case vote
    case removeVote(wishId: String)
    case comments(wishId: String)
    case createComment
    case categories(projectId: String)

    // Roadmap
    case roadmap(projectId: String)

    // Support
    case supportTickets(projectId: String)
    case supportTicket(id: String)
    case createSupportTicket
    case supportMessages(ticketId: String)
    case createSupportMessage
    case supportRequestsMy(projectId: String, email: String?, externalUserId: String?, page: Int, perPage: Int)
    case supportForms(projectId: String)
    case supportForm(projectId: String, formId: String)
    case submitSupportForm(projectId: String, formId: String)

    // Survey
    case survey(slug: String)
    case submitSurveyResponse(surveyId: String)

    // Help Center
    case helpCollections(projectId: String)
    case helpArticles(projectId: String)
    case helpArticle(slug: String)

    // Contact Form
    case contactForms(projectId: String)
    case contactForm(projectId: String, formId: String)
    case standaloneForm(formId: String)
    case submitContactForm(projectId: String, formId: String)

    // File Upload
    case uploadFile

    // Customization
    case customization(projectId: String)

    // Status Pages
    case statusOverview(projectId: String, slug: String)
    case statusServices(statusPageId: String)

    // Releases
    case releases(orgSlug: String, projectSlug: String, limit: Int)
    case release(orgSlug: String, projectSlug: String, releaseSlug: String)
    case releaseFeatures(releaseId: String)

    var path: String {
        switch self {
        case .wishes:
            return "/portal/wishes"
        case .createWish:
            return "/portal/wishes"
        case .wish(let id):
            return "/portal/wishes/\(id)"
        case .vote:
            return "/portal/votes"
        case .removeVote(let wishId):
            return "/portal/votes/\(wishId)"
        case .comments:
            return "/api/v1/comments"
        case .createComment:
            return "/api/v1/comments"
        case .categories:
            return "/portal/categories"
        case .roadmap:
            return "/portal/roadmap-data"
        case .supportTickets:
            return "/portal/support/tickets"
        case .supportTicket(let id):
            return "/portal/support/tickets/\(id)"
        case .createSupportTicket:
            return "/portal/support/tickets"
        case .supportMessages(let ticketId):
            return "/portal/support/tickets/\(ticketId)/messages"
        case .createSupportMessage:
            return "/portal/support/messages"
        case .supportRequestsMy:
            return "/portal/support-requests/my"
        case .supportForms(let projectId):
            return "/api/v1/projects/\(projectId)/support-forms"
        case .supportForm(let projectId, let formId):
            return "/api/v1/projects/\(projectId)/support-forms/\(formId)"
        case .submitSupportForm(let projectId, let formId):
            return "/api/v1/projects/\(projectId)/support-forms/\(formId)/submit"
        case .survey(let slug):
            return "/portal/surveys/\(slug)"
        case .submitSurveyResponse(let surveyId):
            return "/portal/surveys/\(surveyId)/responses"
        case .helpCollections:
            return "/portal/help"
        case .helpArticles:
            return "/portal/help/articles"
        case .helpArticle(let slug):
            return "/portal/help/articles/\(slug)"
        case .contactForms(let projectId):
            return "/api/v1/projects/\(projectId)/contact-forms"
        case .contactForm(let projectId, let formId):
            return "/api/v1/projects/\(projectId)/contact-forms/\(formId)"
        case .standaloneForm(let formId):
            return "/api/v1/forms/\(formId)"
        case .submitContactForm(let projectId, let formId):
            return "/api/v1/projects/\(projectId)/contact-forms/\(formId)/submit"
        case .uploadFile:
            return "/portal/files/upload"
        case .customization(let projectId):
            return "/api/v1/projects/\(projectId)/customization/effective"
        case .statusOverview(let projectId, let slug):
            return "/api/v1/status-pages/public/\(projectId)/\(slug)/overview"
        case .statusServices(let statusPageId):
            return "/api/v1/status-page-services"
        case .releases(let orgSlug, let projectSlug, _):
            return "/api/v1/releases/public/\(orgSlug)/\(projectSlug)"
        case .release(let orgSlug, let projectSlug, let releaseSlug):
            return "/api/v1/releases/public/\(orgSlug)/\(projectSlug)/\(releaseSlug)"
        case .releaseFeatures(let releaseId):
            return "/api/v1/releases/\(releaseId)/features"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .wishes, .wish, .comments, .categories, .customization, .roadmap,
             .supportTickets, .supportTicket, .supportMessages, .supportRequestsMy, .supportForms, .supportForm,
             .survey, .helpCollections, .helpArticles, .helpArticle, .contactForms, .contactForm, .standaloneForm,
             .statusOverview, .statusServices, .releases, .release, .releaseFeatures:
            return .get
        case .createWish, .vote, .createComment, .createSupportTicket,
             .createSupportMessage, .uploadFile, .submitSurveyResponse, .submitContactForm, .submitSupportForm:
            return .post
        case .removeVote:
            return .delete
        }
    }

    func queryItems(projectId: String? = nil, filters: WishFilters? = nil, wishId: String? = nil, searchQuery: String? = nil, supportRequestFilters: SupportRequestFilters? = nil) -> [URLQueryItem] {
        var items: [URLQueryItem] = []

        switch self {
        case .wishes(let pid):
            items.append(URLQueryItem(name: "project_id", value: pid))
            if let filters = filters {
                if let status = filters.status {
                    items.append(URLQueryItem(name: "status", value: status.rawValue))
                }
                if let categoryId = filters.categoryId {
                    items.append(URLQueryItem(name: "category_id", value: categoryId))
                }
                if let search = filters.searchQuery, !search.isEmpty {
                    items.append(URLQueryItem(name: "search", value: search))
                }
                items.append(URLQueryItem(name: "sort", value: filters.sortBy.rawValue))
                items.append(URLQueryItem(name: "page", value: String(filters.page)))
                items.append(URLQueryItem(name: "limit", value: String(filters.limit)))
            }
        case .comments:
            if let wishId = wishId {
                items.append(URLQueryItem(name: "wish_id", value: wishId))
            }
        case .categories(let pid):
            items.append(URLQueryItem(name: "project_id", value: pid))
        case .roadmap(let pid):
            items.append(URLQueryItem(name: "project_id", value: pid))
        case .supportTickets(let pid):
            items.append(URLQueryItem(name: "project_id", value: pid))
        case .supportRequestsMy(let pid, let email, let externalUserId, let page, let perPage):
            items.append(URLQueryItem(name: "project_id", value: pid))
            if let email = email {
                items.append(URLQueryItem(name: "email", value: email))
            }
            if let externalUserId = externalUserId {
                items.append(URLQueryItem(name: "external_user_id", value: externalUserId))
            }
            items.append(URLQueryItem(name: "page", value: String(page)))
            items.append(URLQueryItem(name: "per_page", value: String(perPage)))
        case .helpCollections(let pid):
            items.append(URLQueryItem(name: "project_id", value: pid))
        case .helpArticles(let pid):
            items.append(URLQueryItem(name: "project_id", value: pid))
            if let search = searchQuery, !search.isEmpty {
                items.append(URLQueryItem(name: "search", value: search))
            }
        case .survey:
            if let pid = projectId {
                items.append(URLQueryItem(name: "project_id", value: pid))
            }
        case .statusServices(let statusPageId):
            items.append(URLQueryItem(name: "status_page_id", value: statusPageId))
        case .releases(_, _, let limit):
            items.append(URLQueryItem(name: "limit", value: String(limit)))
        case .supportForms(let pid):
            items.append(URLQueryItem(name: "project_id", value: pid))
        case .supportForm(let pid, _):
            items.append(URLQueryItem(name: "project_id", value: pid))
        default:
            break
        }

        return items
    }
}

internal enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}
