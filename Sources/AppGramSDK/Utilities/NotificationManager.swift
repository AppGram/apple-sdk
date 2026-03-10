import Foundation

public class NotificationManager: @unchecked Sendable {
    public enum NotificationEvent: Sendable {
        case newStatusUpdate(StatusUpdate)
        case statusResolved(StatusUpdate)
        case newRelease(Release)
    }

    public typealias NotificationHandler = @Sendable (NotificationEvent) -> Void

    private let lock = NSLock()
    private var subscriptions: [UUID: NotificationHandler] = [:]
    private var previousStatusUpdateIds: Set<String> = []
    private var previousReleaseIds: Set<String> = []

    public init() {}

    public func subscribe(handler: @escaping NotificationHandler) -> UUID {
        let token = UUID()
        lock.lock()
        subscriptions[token] = handler
        lock.unlock()
        logDebug("NotificationManager: Subscription added with token \(token)")
        return token
    }

    public func unsubscribe(token: UUID) {
        lock.lock()
        subscriptions.removeValue(forKey: token)
        lock.unlock()
        logDebug("NotificationManager: Subscription removed for token \(token)")
    }

    public func checkForNewStatusUpdates(_ updates: [StatusUpdate]) {
        lock.lock()
        let handlers = Array(subscriptions.values)
        lock.unlock()

        for update in updates {
            if !previousStatusUpdateIds.contains(update.id) {
                logDebug("NotificationManager: New status update detected: \(update.title)")
                for handler in handlers {
                    handler(.newStatusUpdate(update))
                }
                previousStatusUpdateIds.insert(update.id)
            }
        }
    }

    public func checkForResolvedStatusUpdates(_ updates: [StatusUpdate]) {
        lock.lock()
        let handlers = Array(subscriptions.values)
        lock.unlock()

        for update in updates where update.state == .resolved {
            logDebug("NotificationManager: Status update resolved: \(update.title)")
            for handler in handlers {
                handler(.statusResolved(update))
            }
            previousStatusUpdateIds.remove(update.id)
        }
    }

    public func checkForNewReleases(_ releases: [Release]) {
        lock.lock()
        let handlers = Array(subscriptions.values)
        lock.unlock()

        for release in releases {
            if !previousReleaseIds.contains(release.id) {
                logDebug("NotificationManager: New release detected: \(release.title)")
                for handler in handlers {
                    handler(.newRelease(release))
                }
                previousReleaseIds.insert(release.id)
            }
        }
    }
}
