# Configuration

Configure AppGramSDK with custom themes and settings.

## Overview

AppGramSDK provides extensive configuration options to customize the appearance and behavior of all components.

## API Key Configuration

Configure an API key for authenticated requests to the AppGram API. The API key will be included in the `X-API-Key` header of all HTTP requests.

```swift
AppGramSDK.shared.configure(
    projectId: "your-project-id",
    baseURL: "https://api.appgram.dev",
    apiKey: "your-api-key" // Optional: for authenticated requests
)
```

> Note: The API key is optional. If not provided, requests will be made without authentication. Some endpoints may require authentication depending on your AppGram project settings.

## Theme Configuration

Create a custom theme to match your app's design:

```swift
let customTheme = AppGramTheme(
    colors: .custom(
        primary: Color.blue,
        secondary: Color.purple,
        accent: Color.orange,
        background: Color(.systemBackground),
        text: Color.primary,
        error: Color.red,
        success: Color.green
    ),
    typography: .default,
    spacing: .default
)

AppGramSDK.shared.configure(
    projectId: "your-project-id",
    baseURL: "https://api.appgram.dev",
    theme: customTheme,
    apiKey: "your-api-key" // Optional
)
```

## Status Page Configuration

Customize the status page appearance:

```swift
let statusConfig = StatusConfiguration(
    title: "System Health",
    autoRefreshInterval: 60, // 60 seconds
    enableAutoRefresh: true,
    cardCornerRadius: 12,
    cardShadowRadius: 2,
    accentColor: .blue
)

let statusView = try? AppGramSDK.shared.statusPageView(
    slug: "status",
    configuration: statusConfig
)
```

## Releases Configuration

Customize the releases view:

```swift
let releasesConfig = ReleasesConfiguration(
    title: "What's New",
    showVersionBadge: true,
    cardCornerRadius: 12,
    imageCornerRadius: 8,
    accentColor: .purple
)

let releasesView = try? AppGramSDK.shared.releasesView(
    orgSlug: "your-org",
    projectSlug: "your-project",
    configuration: releasesConfig
)
```

## Announcement Configuration

Configure the announcement system to automatically show release announcements to users:

```swift
let announcementConfig = AnnouncementConfiguration(
    orgSlug: "your-org",
    projectSlug: "your-project",
    showOnLaunch: true,              // Show announcements on app launch
    minimumHoursBetweenShows: 24,    // Minimum hours between automatic shows
    maxAnnouncementsToShow: 3        // Maximum announcements to show at once
)

AppGramSDK.shared.configure(
    projectId: "your-project-id",
    baseURL: "https://api.appgram.dev",
    apiKey: "your-api-key",
    announcementConfiguration: announcementConfig
)
```

### Manual Announcement Display

You can also manually trigger announcements:

```swift
// Show announcements manually (e.g., from a "What's New" button)
Task { @MainActor in
    await AppGramSDK.shared.showAnnouncements()
}
```

> **Important:** You must provide `announcementConfiguration` when calling `configure()` for the announcement system to work. Without it, `showAnnouncements()` will log a warning and return early.

## Deep Linking

Handle deep links to status updates and releases:

```swift
@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if let deepLink = DeepLinkHandler.parse(url: url) {
                        switch deepLink {
                        case .statusUpdate(let projectId, let updateSlug):
                            // Navigate to status update
                            print("Navigate to status update: \(updateSlug)")
                        case .release(let orgSlug, let projectSlug, let releaseSlug):
                            // Navigate to release
                            print("Navigate to release: \(releaseSlug)")
                        }
                    }
                }
        }
    }
}
```

Supported URL schemes:
- `appgram://status/PROJECT_ID/update/UPDATE_SLUG`
- `appgram://releases/ORG/PROJECT/RELEASE_SLUG`

## Notification Callbacks

Subscribe to notifications for status updates and releases:

```swift
let notificationManager = try? AppGramSDK.shared.getNotificationManager()

let token = notificationManager?.subscribe { event in
    switch event {
    case .newStatusUpdate(let update):
        // Handle new status update
        print("New status update: \(update.title)")
        // Send push notification via your service

    case .statusResolved(let update):
        // Handle resolved status
        print("Status resolved: \(update.title)")

    case .newRelease(let release):
        // Handle new release
        print("New release: \(release.title)")
    }
}

// Later, unsubscribe
if let token = token {
    notificationManager?.unsubscribe(token: token)
}
```

## Auto-Refresh

Configure auto-refresh for status pages:

```swift
// Enable auto-refresh with custom interval
let config = StatusConfiguration(
    autoRefreshInterval: 30, // 30 seconds (default)
    enableAutoRefresh: true
)

// Disable auto-refresh
let configNoRefresh = StatusConfiguration(
    enableAutoRefresh: false
)
```

## UIKit Integration

Use the SDK with UIKit:

```swift
import UIKit
import AppGramSDK

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Present status page
        if let statusVC = try? AppGramSDK.statusPageViewController() {
            navigationController?.pushViewController(statusVC, animated: true)
        }

        // Present releases
        if let releasesVC = try? AppGramSDK.releasesViewController(
            orgSlug: "your-org",
            projectSlug: "your-project"
        ) {
            navigationController?.pushViewController(releasesVC, animated: true)
        }
    }
}
```
