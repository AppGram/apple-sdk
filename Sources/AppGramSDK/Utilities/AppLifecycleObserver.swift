import Foundation

#if canImport(UIKit)
import UIKit

/// Observes app lifecycle events and provides callbacks for key events.
///
/// This class monitors UIApplication notifications for app launch, foreground,
/// and background events, making it easy to respond to app lifecycle changes.
///
/// ## Example
/// ```swift
/// let observer = AppLifecycleObserver()
/// observer.onLaunch = {
///     print("App launched!")
/// }
/// observer.onForeground = {
///     print("App entered foreground")
/// }
/// ```
@MainActor
public class AppLifecycleObserver: ObservableObject {
    private var observers: [NSObjectProtocol] = []

    /// Called when the app finishes launching.
    public var onLaunch: (() -> Void)?

    /// Called when the app enters the foreground.
    public var onForeground: (() -> Void)?

    /// Called when the app enters the background.
    public var onBackground: (() -> Void)?

    public init() {
        setupObservers()
    }

    private func setupObservers() {
        // Observe app launch
        let launchObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didFinishLaunchingNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onLaunch?()
        }

        // Observe app entering foreground
        let foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onForeground?()
        }

        // Observe app entering background
        let backgroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didEnterBackgroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.onBackground?()
        }

        observers = [launchObserver, foregroundObserver, backgroundObserver]
    }

    deinit {
        // Remove all observers
        observers.forEach { observer in
            NotificationCenter.default.removeObserver(observer)
        }
    }
}
#endif
