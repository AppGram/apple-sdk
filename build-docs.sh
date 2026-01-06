#!/bin/bash

# build-docs.sh - Build DocC documentation for AppGramSDK
# This script builds the DocC archive and exports it for use with docc2json

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCHEME_NAME="AppGramSDK"
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${PROJECT_DIR}/.build"
DERIVED_DATA="${BUILD_DIR}/DerivedData"
DOCS_OUTPUT="${PROJECT_DIR}/docs"
DOCCARCHIVE_NAME="${SCHEME_NAME}.doccarchive"

echo -e "${GREEN}Building DocC documentation for ${SCHEME_NAME}${NC}"
echo "Project directory: ${PROJECT_DIR}"
echo ""

# Clean previous builds
echo -e "${YELLOW}Cleaning previous builds...${NC}"
rm -rf "${BUILD_DIR}"
rm -rf "${DOCS_OUTPUT}"
mkdir -p "${BUILD_DIR}"
mkdir -p "${DOCS_OUTPUT}"

# Build documentation
echo -e "${YELLOW}Building documentation archive...${NC}"
xcodebuild docbuild \
    -scheme "${SCHEME_NAME}" \
    -derivedDataPath "${DERIVED_DATA}" \
    -destination 'generic/platform=iOS' \
    | grep -v '^$' || true

# Find the generated .doccarchive
DOCCARCHIVE_PATH=$(find "${DERIVED_DATA}" -name "${DOCCARCHIVE_NAME}" | head -1)

if [ -z "$DOCCARCHIVE_PATH" ]; then
    echo -e "${RED}Error: Could not find ${DOCCARCHIVE_NAME}${NC}"
    echo "Searched in: ${DERIVED_DATA}"
    exit 1
fi

echo -e "${GREEN}Found DocC archive at: ${DOCCARCHIVE_PATH}${NC}"

# Copy to docs directory
echo -e "${YELLOW}Copying archive to docs directory...${NC}"
cp -R "${DOCCARCHIVE_PATH}" "${DOCS_OUTPUT}/${DOCCARCHIVE_NAME}"

# Extract data folder for legacy compatibility
echo -e "${YELLOW}Extracting data folder...${NC}"
if [ -d "${DOCS_OUTPUT}/${DOCCARCHIVE_NAME}/data" ]; then
    cp -R "${DOCS_OUTPUT}/${DOCCARCHIVE_NAME}/data" "${DOCS_OUTPUT}/data"
    echo -e "${GREEN}Data folder extracted to: ${DOCS_OUTPUT}/data${NC}"
fi

# Print summary
echo ""
echo -e "${GREEN}✓ Documentation build complete!${NC}"
echo ""
echo "Outputs:"
echo "  - Full archive: ${DOCS_OUTPUT}/${DOCCARCHIVE_NAME}"
echo "  - Data folder:  ${DOCS_OUTPUT}/data"
echo ""
echo "You can now use either:"
echo "  docc2json -i ${DOCS_OUTPUT}/${DOCCARCHIVE_NAME} -o sdk.json"
echo "  docc2json -i ${DOCS_OUTPUT}/data -o sdk.json"
echo ""

# Optional: Count documentation files
JSON_COUNT=$(find "${DOCS_OUTPUT}/data" -name "*.json" -type f 2>/dev/null | wc -l | tr -d ' ')
echo "Generated ${JSON_COUNT} documentation files"
