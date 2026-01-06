import Foundation

public class DeepLinkHandler {
    public enum DeepLink: Sendable {
        case statusUpdate(projectId: String, updateSlug: String)
        case release(orgSlug: String, projectSlug: String, releaseSlug: String)
    }

    public static func parse(url: URL) -> DeepLink? {
        guard url.scheme == "appgram" else {
            logDebug("DeepLinkHandler: Invalid scheme, expected 'appgram', got '\(url.scheme ?? "nil")'")
            return nil
        }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch url.host {
        case "status":
            // appgram://status/PROJECT_ID/update/UPDATE_SLUG
            guard pathComponents.count == 3,
                  pathComponents[1] == "update" else {
                logDebug("DeepLinkHandler: Invalid status update URL format")
                return nil
            }
            return .statusUpdate(projectId: pathComponents[0], updateSlug: pathComponents[2])

        case "releases":
            // appgram://releases/ORG/PROJECT/RELEASE_SLUG
            guard pathComponents.count == 3 else {
                logDebug("DeepLinkHandler: Invalid release URL format")
                return nil
            }
            return .release(
                orgSlug: pathComponents[0],
                projectSlug: pathComponents[1],
                releaseSlug: pathComponents[2]
            )

        default:
            logDebug("DeepLinkHandler: Unknown host: \(url.host ?? "nil")")
            return nil
        }
    }
}
