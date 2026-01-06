#!/bin/bash

# validate-docs.sh - Validate DocC documentation structure
# Checks if the generated documentation has the expected structure

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOCS_PATH="${1:-docs}"

if [ ! -d "$DOCS_PATH" ]; then
    echo -e "${RED}Error: Documentation path not found: $DOCS_PATH${NC}"
    exit 1
fi

echo -e "${BLUE}Validating documentation at: $DOCS_PATH${NC}"
echo ""

# Check for .doccarchive
DOCCARCHIVE=$(find "$DOCS_PATH" -name "*.doccarchive" -type d | head -1)
if [ -n "$DOCCARCHIVE" ]; then
    echo -e "${GREEN}✓ Found .doccarchive: $(basename "$DOCCARCHIVE")${NC}"
else
    echo -e "${YELLOW}⚠ No .doccarchive found${NC}"
fi

# Check for data folder
if [ -d "$DOCS_PATH/data" ]; then
    echo -e "${GREEN}✓ Found data folder${NC}"

    # Count JSON files
    JSON_COUNT=$(find "$DOCS_PATH/data" -name "*.json" -type f | wc -l | tr -d ' ')
    echo -e "  ${BLUE}→ JSON files: $JSON_COUNT${NC}"

    # Check for module file
    MODULE_JSON=$(find "$DOCS_PATH/data/documentation" -maxdepth 1 -name "*.json" -type f | head -1)
    if [ -n "$MODULE_JSON" ]; then
        MODULE_NAME=$(basename "$MODULE_JSON" .json)
        echo -e "  ${BLUE}→ Module: $MODULE_NAME${NC}"

        # Check if it's a module or class
        SYMBOL_KIND=$(jq -r '.metadata.symbolKind // "unknown"' "$MODULE_JSON" 2>/dev/null)
        echo -e "  ${BLUE}→ Root symbol kind: $SYMBOL_KIND${NC}"

        # Count symbols with abstracts in module references
        if [ "$SYMBOL_KIND" = "module" ]; then
            ABSTRACT_COUNT=$(jq '[.references | to_entries[] | select(.value.abstract and (.value.abstract | length) > 0)] | length' "$MODULE_JSON" 2>/dev/null)
            echo -e "  ${BLUE}→ Symbols with documentation: $ABSTRACT_COUNT${NC}"
        fi
    fi
else
    echo -e "${RED}✗ No data folder found${NC}"
fi

# Sample some documentation
echo ""
echo -e "${BLUE}Sample documented symbols:${NC}"
if [ -d "$DOCS_PATH/data" ]; then
    find "$DOCS_PATH/data" -name "*.json" -type f | head -5 | while read -r file; do
        TITLE=$(jq -r '.metadata.title // "unknown"' "$file" 2>/dev/null)
        KIND=$(jq -r '.metadata.symbolKind // "unknown"' "$file" 2>/dev/null)
        echo -e "  ${GREEN}→${NC} $TITLE ${YELLOW}($KIND)${NC}"
    done
fi

echo ""
echo -e "${GREEN}Validation complete!${NC}"
