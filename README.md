# AppGram iOS SDK

A comprehensive iOS SDK for integrating customer engagement features including feedback collection, support tickets, help centers, roadmaps, release notes, status pages, and more.

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
[![SPM](https://img.shields.io/badge/SPM-Compatible-green.svg)](https://swift.org/package-manager/)

## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 5.9+
- Xcode 15.0+

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/AppGram/apple-sdk.git", branch: "main")
]
```

Or in Xcode:
1. Go to **File > Add Package Dependencies**
2. Enter: `https://github.com/AppGram/apple-sdk.git`
3. Select **Branch: main** and add to your target

## Quick Start

### 1. Configure the SDK

Initialize the SDK early in your app's lifecycle, typically in your `App` struct or `AppDelegate`:

```swift
import AppGramSDK

@main
struct MyApp: App {
    init() {
        AppGramSDK.shared.configure(
            projectId: "your-project-id",
            apiKey: "your-api-key"  // Optional, for authenticated endpoints
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

### 2. Set User Context (Optional)

Identify users to associate feedback and support tickets:

```swift
AppGramSDK.shared.setUser(
    userId: "user-123",
    email: "user@example.com",
    name: "John Doe"
)

// Clear user on logout
AppGramSDK.shared.clearUser()
```

### 3. Display Views

```swift
import SwiftUI
import AppGramSDK

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Feedback") {
                    try? AppGramSDK.shared.feedbackView()
                }
                NavigationLink("Support") {
                    try? AppGramSDK.shared.supportView()
                }
                NavigationLink("Help Center") {
                    try? AppGramSDK.shared.helpCenterView()
                }
            }
        }
    }
}
```

## Features

### Feedback & Wishboard

Collect feature requests and feedback from users with voting capabilities:

```swift
// Display feedback view
let feedbackView = try AppGramSDK.shared.feedbackView()

// Or use the service directly
let feedbackService = try AppGramSDK.shared.getFeedbackService()
let wishes = try await feedbackService.getWishes()

// Create a new feature request
let wish = try await feedbackService.createWish(
    title: "Dark mode support",
    description: "Please add dark mode to the app",
    categoryId: nil
)

// Vote on a wish
try await feedbackService.addVote(wishId: wish.id)
```

### Support Tickets

Full support ticket system with local storage:

```swift
// Display support view
let supportView = try AppGramSDK.shared.supportView()

// Display a specific support form
let formView = try AppGramSDK.shared.supportFormView(formId: "form-123")

// Use the service directly
let supportService = try AppGramSDK.shared.getSupportService()

// Create a ticket
let ticket = try await supportService.createTicket(
    subject: "Login issue",
    description: "I can't log into my account",
    priority: .normal,
    email: "user@example.com",
    attachmentUrls: nil
)
```

### Help Center

Interactive help center with articles, flows, and decision trees:

```swift
// Basic help center
let helpView = try AppGramSDK.shared.helpCenterView()

// With custom configuration
let config = HelpCenterConfiguration(
    yesButtonColor: .green,
    noButtonColor: .red,
    articleBehavior: .pushToStack
)
let helpView = try AppGramSDK.shared.helpCenterView(configuration: config)

// Access articles programmatically
let helpService = try AppGramSDK.shared.getHelpService()
let collections = try await helpService.getCollections()
let article = try await helpService.getArticle(slug: "getting-started")
```

### Roadmap

Display your product roadmap:

```swift
let roadmapView = try AppGramSDK.shared.roadmapView()

// Access roadmap data
let roadmapService = try AppGramSDK.shared.getRoadmapService()
let items = try await roadmapService.getRoadmapItems()
```

### Release Notes

Showcase new features and updates:

```swift
let releasesView = try AppGramSDK.shared.releasesView(
    orgSlug: "your-org",
    projectSlug: "your-project"
)

// With configuration
let config = ReleasesConfiguration(
    showVersionBadge: true,
    dateFormat: "MMM d, yyyy"
)
let releasesView = try AppGramSDK.shared.releasesView(
    orgSlug: "your-org",
    projectSlug: "your-project",
    configuration: config
)
```

### Status Page

Display system status and service health:

```swift
let statusView = try AppGramSDK.shared.statusPageView(slug: "status")

// With subscription callback
let config = StatusConfiguration(
    onSubscribe: { email in
        print("User subscribed: \(email)")
    }
)
let statusView = try AppGramSDK.shared.statusPageView(
    slug: "status",
    configuration: config
)
```

### Contact Forms

Custom contact forms:

```swift
let contactView = try AppGramSDK.shared.contactFormView(formId: "contact-123")
```

### Surveys

Collect user feedback with surveys:

```swift
// Standard survey
let surveyView = try AppGramSDK.shared.surveyView(slug: "nps-survey")

// Typeform-style survey
let surveyView = try AppGramSDK.shared.surveyView(
    slug: "onboarding",
    style: .typeform
)
```

### Blog

Display blog posts and content:

```swift
let blogView = try AppGramSDK.shared.blogView()

let blogService = try AppGramSDK.shared.getBlogService()
let posts = try await blogService.getPosts()
```

## Theming

### Built-in Themes

```swift
AppGramSDK.shared.configure(
    projectId: "your-project-id",
    theme: .ocean  // .default, .forest, .sunset, .minimal, .classic, .slate, .neutral
)
```

### Custom Theme

```swift
let customTheme = AppGramTheme(
    colors: ColorPalette(
        primary: .blue,
        secondary: .purple,
        accent: .orange,
        background: .white,
        text: .black,
        cardBackground: .gray.opacity(0.1),
        border: .gray.opacity(0.2),
        success: .green,
        warning: .yellow,
        error: .red,
        neutral50: Color(white: 0.98),
        neutral100: Color(white: 0.96),
        neutral200: Color(white: 0.90),
        neutral300: Color(white: 0.83),
        neutral400: Color(white: 0.64),
        neutral500: Color(white: 0.45),
        neutral600: Color(white: 0.32),
        neutral700: Color(white: 0.25),
        neutral800: Color(white: 0.15),
        neutral900: Color(white: 0.09)
    ),
    darkColors: nil  // Optional dark mode colors
)

AppGramSDK.shared.configure(
    projectId: "your-project-id",
    theme: customTheme
)
```

## Auto-Popups

Automatically show feedback prompts or surveys based on conditions:

```swift
let popupConfig = PopupConfiguration(
    trigger: .afterLaunches(5),
    content: .feedback,
    style: .sheet
)

AppGramSDK.shared.configure(
    projectId: "your-project-id",
    popupConfiguration: popupConfig
)

// Start monitoring
let popupManager = try AppGramSDK.shared.getPopupManager()
popupManager.start()

// Show manually
popupManager.showPopupManually()

// Stop monitoring
popupManager.stop()
```

### Trigger Options

- `.afterLaunches(Int)` - After N app launches
- `.afterDaysOfUsage(Int)` - After N days of usage
- `.repeatInterval(TimeInterval)` - Repeat every N seconds
- `.minimumInterval(TimeInterval)` - Minimum time between popups

## Announcements

Display in-app announcements:

```swift
let announcementConfig = AnnouncementCardConfiguration(
    backgroundColor: .blue,
    primaryButtonColor: .white,
    style: .card
)

AppGramSDK.shared.configure(
    projectId: "your-project-id",
    announcementConfiguration: announcementConfig
)

// Show announcements
AppGramSDK.shared.showAnnouncements()

// Or use the manager
let manager = try AppGramSDK.shared.getAnnouncementManager()
manager.presentAnnouncements()
```

## Widgets

Embeddable widgets for your UI:

```swift
let widgetConfig = AGWidgetConfiguration(
    type: .feedback,
    style: .card,
    size: .medium,
    ctaButton: AGWidgetConfiguration.CTAStyle(
        title: "Share Feedback",
        backgroundColor: .blue,
        foregroundColor: .white,
        fontWeight: .semibold,
        cornerRadius: 8
    )
)

let widgetView = try AppGramSDK.shared.widgetView(configuration: widgetConfig)
```

### Widget Types
- `.feedback` - Feedback submission
- `.roadmap` - Roadmap preview
- `.status` - Status indicator
- `.custom` - Custom content

### Widget Styles
- `.card` - Full card layout
- `.minimal` - Minimal design
- `.compact` - Compact view
- `.banner` - Banner style

## UIKit Support

All views have UIKit equivalents:

```swift
import UIKit
import AppGramSDK

class MyViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        let feedbackVC = try? AppGramSDK.shared.feedbackViewController()
        if let vc = feedbackVC {
            navigationController?.pushViewController(vc, animated: true)
        }
    }
}
```

Available UIKit methods:
- `feedbackViewController()`
- `supportViewController()`
- `helpCenterViewController()`
- `roadmapViewController()`
- `statusPageViewController()`
- `releasesViewController()`
- `contactFormViewController()`
- `surveyViewController()`
- `blogViewController()`

## Error Handling

```swift
do {
    let service = try AppGramSDK.shared.getFeedbackService()
    let wishes = try await service.getWishes()
} catch AppGramError.notConfigured {
    print("SDK not configured")
} catch AppGramError.networkError(let message) {
    print("Network error: \(message)")
} catch AppGramError.unauthorized {
    print("Unauthorized - check API key")
} catch {
    print("Error: \(error)")
}
```

### Error Types

| Error | Description |
|-------|-------------|
| `notConfigured` | SDK not initialized |
| `networkError(String)` | Network request failed |
| `invalidResponse` | Malformed server response |
| `decodingError(String)` | JSON parsing failed |
| `validationError(String)` | Input validation failed |
| `uploadFailed` | File upload error |
| `unauthorized` | Authentication required |
| `forbidden` | Access denied |
| `notFound` | Resource not found |
| `serverError(Int)` | Server error with HTTP code |

## Logging

Enable debug logging during development:

```swift
// Logs are automatically enabled in DEBUG builds
// View logs in Xcode console with "AppGram" filter
```

## Thread Safety

The SDK is thread-safe and can be accessed from any thread. UI-related operations are automatically dispatched to the main thread.

## Complete Example

```swift
import SwiftUI
import AppGramSDK

@main
struct MyApp: App {
    init() {
        // Configure SDK
        AppGramSDK.shared.configure(
            projectId: "your-project-id",
            theme: .default,
            apiKey: "your-api-key"
        )

        // Set user if logged in
        if let user = AuthManager.shared.currentUser {
            AppGramSDK.shared.setUser(
                userId: user.id,
                email: user.email,
                name: user.name
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var showFeedback = false
    @State private var showSupport = false

    var body: some View {
        NavigationStack {
            List {
                Section("Engage") {
                    Button("Share Feedback") { showFeedback = true }
                    Button("Get Support") { showSupport = true }
                }

                Section("Info") {
                    NavigationLink("Roadmap") {
                        try? AppGramSDK.shared.roadmapView()
                    }
                    NavigationLink("Help Center") {
                        try? AppGramSDK.shared.helpCenterView()
                    }
                    NavigationLink("Status") {
                        try? AppGramSDK.shared.statusPageView(slug: "status")
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showFeedback) {
                NavigationStack {
                    try? AppGramSDK.shared.feedbackView()
                }
            }
            .sheet(isPresented: $showSupport) {
                NavigationStack {
                    try? AppGramSDK.shared.supportView()
                }
            }
        }
    }
}
```

## License

Copyright 2026 AppGram. All rights reserved.
