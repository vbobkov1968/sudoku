#!/bin/bash
set -e

APP_NAME="Sudoku"
VERSION="1.2.0"
BUILD_DIR="sudoku_app/build/macos/Build/Products/Release"
STAGING="sudoku_app/build/dmg_staging"
OUT="sudoku_app/build/$APP_NAME-$VERSION.dmg"

if [ ! -d "$BUILD_DIR/$APP_NAME.app" ]; then
  echo "Release app not found. Run 'flutter build macos --release' first."
  exit 1
fi

rm -rf "$STAGING"
mkdir -p "$STAGING"

echo "Copying $APP_NAME.app..."
cp -R "$BUILD_DIR/$APP_NAME.app" "$STAGING/$APP_NAME.app"

echo "Creating Applications alias..."
STAGING_ABS=$(cd "$STAGING" && pwd)
osascript <<APPLESCRIPT
tell application "Finder"
    make alias file to POSIX file "/Applications" at POSIX file "$STAGING_ABS"
end tell
APPLESCRIPT
# AppleScript may name it "Applications alias" depending on locale
if [ -e "$STAGING/Applications alias" ]; then
    mv "$STAGING/Applications alias" "$STAGING/Applications"
fi

echo "Creating README..."
cat > "$STAGING/README.txt" << 'EOF'
Установка / Installation
========================

Перетащите Sudoku.app в папку Applications.

Drag Sudoku.app into the Applications folder.


Если macOS блокирует запуск / If macOS blocks the app
------------------------------------------------------

Выполните в Терминале:

    xattr -cr /Applications/Sudoku.app

Run in Terminal:

    xattr -cr /Applications/Sudoku.app
EOF

echo "Building DMG..."
rm -f "$OUT"
hdiutil create \
  -volname "$APP_NAME $VERSION" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$OUT"

rm -rf "$STAGING"

echo ""
echo "Done: $OUT"
