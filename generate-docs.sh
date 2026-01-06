#!/bin/bash

# AppGramSDK Documentation Generator
# Generates DocC documentation and converts it to static HTML

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
SCHEME="AppGramSDK"
DESTINATION="generic/platform=iOS"
DERIVED_DATA_PATH="./build"
OUTPUT_PATH="./docs"
HOSTING_BASE_PATH="AppGramSDK"

# Option to generate for local viewing (without base path)
# Set to "true" to generate docs that work when opening index.html directly
# Set to "false" to generate docs for hosting with base path
LOCAL_VIEWING=true

echo -e "${GREEN}📚 AppGramSDK Documentation Generator${NC}"
echo ""

# Step 1: Build documentation archive
echo -e "${YELLOW}Step 1: Building documentation archive...${NC}"
xcodebuild docbuild \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -derivedDataPath "$DERIVED_DATA_PATH"

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to build documentation${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Documentation archive built successfully${NC}"
echo ""

# Step 2: Find the generated .doccarchive
ARCHIVE_PATH="$DERIVED_DATA_PATH/Build/Products/Debug-iphoneos/$SCHEME.doccarchive"

if [ ! -d "$ARCHIVE_PATH" ]; then
    echo -e "${RED}❌ Documentation archive not found at: $ARCHIVE_PATH${NC}"
    echo "Searching for archive..."
    ARCHIVE_PATH=$(find "$DERIVED_DATA_PATH" -name "$SCHEME.doccarchive" -type d | head -1)
    
    if [ -z "$ARCHIVE_PATH" ]; then
        echo -e "${RED}❌ Could not find documentation archive${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Found archive at: $ARCHIVE_PATH${NC}"
fi

# Step 3: Convert to static HTML
echo -e "${YELLOW}Step 2: Converting to static HTML...${NC}"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_PATH"

if [ "$LOCAL_VIEWING" = "true" ]; then
    echo -e "${YELLOW}   Generating for local viewing (no base path)...${NC}"
    xcrun docc process-archive transform-for-static-hosting \
        "$ARCHIVE_PATH" \
        --output-path "$OUTPUT_PATH"
else
    echo -e "${YELLOW}   Generating for hosting with base path: /$HOSTING_BASE_PATH${NC}"
    xcrun docc process-archive transform-for-static-hosting \
        "$ARCHIVE_PATH" \
        --output-path "$OUTPUT_PATH" \
        --hosting-base-path "$HOSTING_BASE_PATH"
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}❌ Failed to convert documentation to HTML${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Documentation converted to HTML successfully${NC}"
echo ""

# Step 4: Summary
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}✨ Documentation generation complete!${NC}"
echo ""
echo -e "📁 Output directory: ${YELLOW}$OUTPUT_PATH${NC}"
echo ""
echo -e "${YELLOW}⚠️  Note: DocC documentation requires a web server to function properly.${NC}"
echo -e "${YELLOW}   Opening index.html directly (file://) will show a blank page.${NC}"
echo ""
echo -e "${GREEN}🚀 Starting local web server...${NC}"
echo ""

# Check if port 8000 is available
PORT=8000
if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1 ; then
    echo -e "${YELLOW}⚠️  Port $PORT is already in use. Trying port 8001...${NC}"
    PORT=8001
fi

# Start server in background and get PID
cd "$OUTPUT_PATH"
python3 -m http.server $PORT > /dev/null 2>&1 &
SERVER_PID=$!
cd - > /dev/null

# Wait a moment for server to start
sleep 1

# Check if server started successfully
if kill -0 $SERVER_PID 2>/dev/null; then
    echo -e "${GREEN}✅ Server started on port $PORT${NC}"
    echo ""
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}📖 Documentation is now available at:${NC}"
    echo -e "   ${YELLOW}http://localhost:$PORT/index.html${NC}"
    echo ""
    echo -e "${GREEN}🌐 Opening in your default browser...${NC}"
    echo ""
    echo -e "${YELLOW}💡 To stop the server, run:${NC}"
    echo -e "   ${GREEN}kill $SERVER_PID${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    # Open in browser
    sleep 1
    open "http://localhost:$PORT/index.html" 2>/dev/null || \
    xdg-open "http://localhost:$PORT/index.html" 2>/dev/null || \
    echo -e "${YELLOW}   Please manually open: http://localhost:$PORT/index.html${NC}"
else
    echo -e "${RED}❌ Failed to start server${NC}"
    echo ""
    echo -e "${YELLOW}💡 Manual start:${NC}"
    echo -e "   ${GREEN}cd $OUTPUT_PATH && python3 -m http.server $PORT${NC}"
    echo -e "   Then open: ${GREEN}http://localhost:$PORT/index.html${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
fi
