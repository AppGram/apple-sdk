# AppGramSDK Documentation

This document describes how to build and view the SDK documentation.

## Building Documentation

### Using Xcode

The easiest way to build documentation is through Xcode:

1. Open the package in Xcode
2. Select **Product → Build Documentation** (⌃⌘D)
3. The documentation will open in Xcode's Documentation Browser

### Using xcodebuild

Build documentation from the command line:

```bash
xcodebuild docbuild -scheme AppGramSDK -destination 'generic/platform=iOS'
```

The documentation archive will be generated at:
```
~/Library/Developer/Xcode/DerivedData/AppGramSDK-.../Build/Products/Debug-iphoneos/AppGramSDK.doccarchive
```

### Using Swift Package Manager

Build documentation using the Swift-DocC plugin:

```bash
swift package --allow-writing-to-directory ./docs \
    generate-documentation --target AppGramSDK \
    --output-path ./docs
```

### Previewing Documentation Locally

Preview the documentation in your browser:

```bash
swift package --disable-sandbox preview-documentation --target AppGramSDK
```

This will start a local web server and open the documentation in your default browser.

## Documentation Structure

The documentation is organized into the following sections:

### Getting Started
- Installation instructions
- Basic configuration
- Quick start examples

### Status Pages
- `StatusPageView` - Main status page view
- `StatusConfiguration` - Customization options
- `StatusViewModel` - State management
- `StatusType` - Status types and colors
- `StatusUpdate` - Status update model

### Releases
- `ReleasesListView` - Releases list view
- `ReleasesConfiguration` - Customization options
- `ReleasesViewModel` - State management
- `Release` - Release model
- `ReleaseLabel` - Release label types

### Advanced Features
- `DeepLinkHandler` - Deep linking support
- `NotificationManager` - Notification callbacks
- Custom theming
- Auto-refresh configuration

## Documentation Files

The documentation source files are located in:
```
Sources/AppGramSDK/AppGramSDK.docc/
├── AppGramSDK.md          # Main documentation page
├── GettingStarted.md      # Installation and setup
└── Configuration.md       # Advanced configuration
```

## Adding Documentation

### Adding New Articles

1. Create a new `.md` file in `Sources/AppGramSDK/AppGramSDK.docc/`
2. Add the article to the topics list in `AppGramSDK.md`
3. Use standard Markdown syntax with DocC extensions

### Documenting Code

Add documentation comments to your public APIs:

```swift
/// A view that displays the status page.
///
/// Use this view to show real-time service status updates with auto-refresh.
///
/// ## Example
///
/// ```swift
/// let statusView = try? AppGramSDK.shared.statusPageView(
///     slug: "status",
///     configuration: StatusConfiguration(
///         autoRefreshInterval: 30
///     )
/// )
/// ```
public struct StatusPageView: View {
    // ...
}
```

## Publishing Documentation

The documentation archive (`.doccarchive`) can be:

1. **Hosted on a web server** - Upload the archive and serve it as static files
2. **Distributed with releases** - Include it in release assets
3. **Hosted on GitHub Pages** - Convert to static HTML and deploy

### Exporting as Static HTML

```bash
xcodebuild docbuild -scheme AppGramSDK \
    -destination 'generic/platform=iOS' \
    -derivedDataPath ./build

# The .doccarchive is at ./build/Build/Products/Debug-iphoneos/AppGramSDK.doccarchive
```

## Viewing Documentation

### In Xcode

1. Build the documentation (⌃⌘D)
2. Open Developer Documentation (⌘⇧0)
3. Search for "AppGramSDK"

### In Browser

Open the generated `.doccarchive` directory in your browser:

```bash
open ~/Library/Developer/Xcode/DerivedData/AppGramSDK-.../Build/Products/Debug-iphoneos/AppGramSDK.doccarchive/index.html
```

## Continuous Integration

Add documentation building to your CI pipeline:

```yaml
# GitHub Actions example
- name: Build Documentation
  run: |
    xcodebuild docbuild \
      -scheme AppGramSDK \
      -destination 'generic/platform=iOS'
```

## Resources

- [Swift-DocC Documentation](https://www.swift.org/documentation/docc/)
- [Writing Symbol Documentation](https://developer.apple.com/documentation/xcode/writing-symbol-documentation-in-your-source-files)
- [Formatting Documentation](https://developer.apple.com/documentation/xcode/formatting-your-documentation-content)
