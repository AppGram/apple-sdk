# AppGramSDK Resources

This directory contains additional resources for the documentation.

## Adding Images

Place images in this directory and reference them in documentation:

```markdown
![Status Page Example](status-page-example.png)
```

## Adding Code Samples

Create standalone Swift files for code examples:

```swift
// Example: StatusPageExample.swift
import AppGramSDK
import SwiftUI

struct StatusPageExample: View {
    var body: some View {
        if let statusView = try? AppGramSDK.shared.statusPageView() {
            statusView
        }
    }
}
```

## File Organization

```
Resources/
├── README.md                  # This file
├── Images/                    # Screenshots and diagrams
│   ├── status-page-light.png
│   ├── status-page-dark.png
│   ├── releases-list.png
│   └── ...
└── CodeExamples/              # Standalone code examples
    ├── BasicSetup.swift
    ├── CustomTheme.swift
    └── ...
```
