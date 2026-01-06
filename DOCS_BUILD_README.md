# Building DocC Documentation

This directory contains scripts to build and validate DocC documentation for AppGramSDK.

## Scripts

### `build-docs.sh`

Builds the DocC documentation using `xcodebuild` and exports it in the correct format.

**Usage:**

```bash
./build-docs.sh
```

**What it does:**
1. Cleans previous builds
2. Runs `xcodebuild docbuild` to generate the .doccarchive
3. Copies the archive to `docs/AppGramSDK.doccarchive`
4. Extracts the `data` folder to `docs/data` for legacy compatibility
5. Reports statistics about generated files

**Outputs:**
- `docs/AppGramSDK.doccarchive` - Full DocC archive
- `docs/data/` - Extracted documentation data (compatible with docc2json)

### `validate-docs.sh`

Validates the generated documentation structure and shows statistics.

**Usage:**

```bash
./validate-docs.sh [path]
```

**Examples:**

```bash
# Validate default docs directory
./validate-docs.sh

# Validate specific path
./validate-docs.sh docs
./validate-docs.sh docs/AppGramSDK.doccarchive
```

## Complete Workflow

```bash
# 1. Build documentation
./build-docs.sh

# 2. Validate the output
./validate-docs.sh docs

# 3. Convert to SDK JSON (from the docc-to-sdk directory)
cd ../../docc-to-sdk
./bin/docc2json \
  -i ../iOS/AppGramSDK/docs/data \
  --group-by-prefix \
  -o ../../../BetterAppsServer/docs/ios-sdk/sdk.json \
  --filter-protocols "Se,ScA,objc,SE,SQ,SH,SY,SL" \
  --keep-all-conformances
```

## Requirements

- Xcode 14.0 or later
- Command Line Tools installed (`xcode-select --install`)
- jq (for validation script): `brew install jq`

## Troubleshooting

### "xcodebuild: command not found"

Install Xcode Command Line Tools:
```bash
xcode-select --install
```

### "Scheme not found"

Make sure the scheme name in `build-docs.sh` matches your project:
```bash
# Edit build-docs.sh and update:
SCHEME_NAME="YourSchemeName"
```

### Documentation not appearing

Ensure your Swift code has documentation comments:

```swift
/// This is the main SDK class.
///
/// Use this class to initialize and configure the SDK.
///
/// ## Example
/// ```swift
/// let sdk = AppGramSDK.shared
/// sdk.configure(projectId: "your-id")
/// ```
public class AppGramSDK {
    /// Shared singleton instance.
    ///
    /// Use this instead of creating new instances.
    public static let shared = AppGramSDK()

    /// Configure the SDK with your project credentials.
    ///
    /// - Parameter projectId: Your AppGram project ID
    /// - Throws: `AppGramError.invalidConfiguration` if the ID is invalid
    ///
    /// ## Discussion
    /// This must be called before using any SDK features.
    public func configure(projectId: String) throws {
        // ...
    }
}
```

### Build fails with signing errors

The `docbuild` command doesn't require code signing. If you see signing errors, check your scheme settings:

1. Open Xcode
2. Product → Scheme → Edit Scheme
3. Under "Build", ensure "Build for Documentation" is checked
4. Under "Run", set Build Configuration to "Release"

## Continuous Integration

You can run this in CI/CD:

```yaml
# GitHub Actions example
- name: Build Documentation
  run: |
    cd iOS/AppGramSDK
    ./build-docs.sh

- name: Validate Documentation
  run: |
    cd iOS/AppGramSDK
    ./validate-docs.sh docs

- name: Convert to SDK JSON
  run: |
    cd docc-to-sdk
    ./bin/docc2json -i ../iOS/AppGramSDK/docs/data -o sdk.json
```

## Output Structure

```
docs/
├── AppGramSDK.doccarchive/     # Full DocC archive
│   ├── css/
│   ├── data/                    # Documentation JSON
│   ├── documentation/
│   ├── img/
│   ├── index/
│   └── ...
└── data/                        # Extracted for docc2json
    └── documentation/
        ├── appgramsdk.json      # Module file
        └── appgramsdk/          # Symbol files
            ├── survey.json
            ├── logger.json
            └── ...
```
