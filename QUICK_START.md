# Quick Start - Documentation Generation

This guide shows you how to quickly build and convert DocC documentation to JSON.

## One-Line Command

From the iOS SDK directory:

```bash
./build-docs.sh && cd ../../docc-to-sdk && ./bin/docc2json -i ../iOS/AppGramSDK/docs/data --group-by-prefix -o ../../../BetterAppsServer/docs/ios-sdk/sdk.json --filter-protocols "Se,ScA,objc,SE,SQ,SH,SY,SL" --keep-all-conformances
```

## Step-by-Step

### 1. Build Documentation

```bash
cd /path/to/iOS/AppGramSDK
./build-docs.sh
```

**Output:**
- `docs/AppGramSDK.doccarchive` - Full archive
- `docs/data/` - JSON documentation files

### 2. (Optional) Validate

```bash
./validate-docs.sh docs
```

### 3. Convert to SDK JSON

```bash
cd ../../docc-to-sdk
./bin/docc2json \
  -i ../iOS/AppGramSDK/docs/data \
  --group-by-prefix \
  -o output.json
```

**Options:**
- `--group-by-prefix` - Group types by name prefix (Survey, Form, etc.)
- `--filter-protocols` - Remove standard protocol conformances
- `--keep-all-conformances` - Keep all conformances (for debugging)
- `--compact` - Minified JSON output
- `--public-only` - Only include public symbols

## What Gets Extracted

✅ **Type Information:**
- Classes, structs, enums, protocols
- Properties and methods
- Initializers and type methods
- Access levels

✅ **Documentation:**
- Abstract (summary)
- Discussion (detailed description)
- Return values
- Throws information
- Code examples

✅ **Relationships:**
- Protocol conformances
- Inheritance
- Extensions

✅ **Organization:**
- Grouped by prefix (when using `--group-by-prefix`)
- Navigation structure
- Topic sections

## Example Output

```json
{
  "modules": [{
    "name": "AppGramSDK",
    "groups": {
      "Survey": {
        "types": [
          {
            "name": "Survey",
            "description": {
              "abstract": "Represents a survey...",
              "discussion": "Use this to...",
              "examples": [...]
            }
          }
        ]
      }
    }
  }]
}
```

## Troubleshooting

**Script not executable:**
```bash
chmod +x build-docs.sh validate-docs.sh
```

**Documentation not showing:**
Add doc comments to your Swift code:
```swift
/// Your class description
public class MyClass {
    /// Property description
    public var property: String
}
```

**Build fails:**
Make sure you have Xcode Command Line Tools:
```bash
xcode-select --install
```

## See Also

- [DOCS_BUILD_README.md](./DOCS_BUILD_README.md) - Detailed documentation
- [../../docc-to-sdk/README.md](../../docc-to-sdk/README.md) - docc2json tool documentation
