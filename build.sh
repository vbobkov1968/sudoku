#!/bin/bash

# Build & Deploy Helper Script for Sudoku App
# Usage: ./build.sh [command] [args]

set -e

SUDOKU_APP_DIR="sudoku_app"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Sudoku App Build & Deploy Helper${NC}"
echo ""

# Show help if no arguments
if [ $# -eq 0 ]; then
    echo "Available commands:"
    echo ""
    echo -e "${GREEN}Testing:${NC}"
    echo "  ./build.sh test             - Run all tests"
    echo "  ./build.sh analyze          - Run Flutter analyze"
    echo ""
    echo -e "${GREEN}Building:${NC}"
    echo "  ./build.sh macos            - Build macOS release"
    echo "  ./build.sh ios              - Build iOS release"
    echo "  ./build.sh android-apk      - Build Android APK"
    echo "  ./build.sh android-aab      - Build Android AAB"
    echo "  ./build.sh all              - Build all platforms"
    echo ""
    echo -e "${GREEN}Maintenance:${NC}"
    echo "  ./build.sh clean            - Clean build artifacts"
    echo "  ./build.sh prepare          - Prepare for release (analyze + test + clean)"
    echo "  ./build.sh upgrade          - Upgrade Flutter dependencies"
    echo ""
    exit 0
fi

cd "$SUDOKU_APP_DIR"

case "$1" in
    test)
        echo -e "${YELLOW}Running all tests...${NC}"
        fastlane test_all
        ;;
    analyze)
        echo -e "${YELLOW}Running Flutter analyze...${NC}"
        fastlane analyze
        ;;
    macos)
        echo -e "${YELLOW}Building macOS release...${NC}"
        fastlane mac build_macos
        ;;
    ios)
        echo -e "${YELLOW}Building iOS release...${NC}"
        fastlane ios build_ios
        ;;
    android-apk)
        echo -e "${YELLOW}Building Android APK...${NC}"
        fastlane android build_android_apk
        ;;
    android-aab)
        echo -e "${YELLOW}Building Android AAB...${NC}"
        fastlane android build_android_aab
        ;;
    all)
        echo -e "${YELLOW}Building all platforms...${NC}"
        fastlane build_all
        ;;
    clean)
        echo -e "${YELLOW}Cleaning build artifacts...${NC}"
        fastlane clean_builds
        ;;
    prepare)
        echo -e "${YELLOW}Preparing for release...${NC}"
        fastlane prepare_release
        ;;
    upgrade)
        echo -e "${YELLOW}Upgrading dependencies...${NC}"
        fastlane upgrade_dependencies
        ;;
    *)
        echo -e "${YELLOW}Unknown command: $1${NC}"
        echo "Run './build.sh' without arguments to see available commands"
        exit 1
        ;;
esac

echo -e "${GREEN}✅ Done!${NC}"
