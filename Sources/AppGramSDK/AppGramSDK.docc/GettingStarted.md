# Getting Started

Learn how to integrate AppGramSDK into your iOS application.

## Overview

This guide will help you get started with AppGramSDK in your iOS project. The SDK supports Swift Package Manager and requires iOS 17.0 or later.

## Installation

### Swift Package Manager

Add AppGramSDK to your project using Xcode:

1. In Xcode, select **File → Add Package Dependencies**
2. Enter the repository URL
3. Select the version you want to use
4. Click **Add Package**

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/your-org/AppGramSDK", from: "1.0.0")
]
```

## Configuration

Configure the SDK in your app's initialization:

```swift
import AppGramSDK

@main
struct MyApp: App {
    init() {
        // Configure AppGramSDK
        Task { @MainActor in
            AppGramSDK.shared.configure(
                projectId: "your-project-id",
                baseURL: "https://api.appgram.dev",
                apiKey: "your-api-key", // Optional: for authenticated requests
                announcementConfiguration: AnnouncementConfiguration(
                    orgSlug: "your-org",
                    projectSlug: "your-project",
                    showOnLaunch: true,
                    minimumHoursBetweenShows: 24,
                    maxAnnouncementsToShow: 3
                )
            )
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

## Basic Usage

### Display Status Page

```swift
import SwiftUI
import AppGramSDK

struct StatusView: View {
    var body: some View {
        if let statusView = try? AppGramSDK.shared.statusPageView() {
            statusView
        }
    }
}
```

### Display Releases

```swift
import SwiftUI
import AppGramSDK

struct ReleasesView: View {
    var body: some View {
        if let releasesView = try? AppGramSDK.shared.releasesView(
            orgSlug: "your-org",
            projectSlug: "your-project"
        ) {
            releasesView
        }
    }
}
```

## User Context

Set user information for personalized experiences:

```swift
AppGramSDK.shared.setUser(
    userId: "user123",
    email: "user@example.com",
    name: "John Doe"
)
```

## Next Steps

- <doc:Configuration> - Learn about advanced configuration options
- Explore individual feature documentation for detailed usage
