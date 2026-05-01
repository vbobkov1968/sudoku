#!/bin/bash
set -e

APP_NAME="Sudoku"
VERSION="1.2.0"
BUILD_DIR="sudoku_app/build/macos/Build/Products/Release"
STAGING="sudoku_app/build/dmg_staging"
TMP_DMG="sudoku_app/build/${APP_NAME}-${VERSION}-rw.dmg"
OUT="sudoku_app/build/$APP_NAME-$VERSION.dmg"

if [ ! -d "$BUILD_DIR/$APP_NAME.app" ]; then
  echo "Release app not found. Run 'flutter build macos --release' first."
  exit 1
fi

# --- Staging ---
rm -rf "$STAGING"
mkdir -p "$STAGING"

echo "Copying $APP_NAME.app..."
cp -R "$BUILD_DIR/$APP_NAME.app" "$STAGING/$APP_NAME.app"

ln -s /Applications "$STAGING/Applications"

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

# --- Create read-write DMG ---
echo "Creating read-write DMG..."
rm -f "$TMP_DMG" "$OUT"
hdiutil create \
  -volname "$APP_NAME $VERSION" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDRW \
  "$TMP_DMG"

rm -rf "$STAGING"

# --- Mount ---
echo "Mounting..."
DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "$TMP_DMG" \
  | grep -E '^/dev/' | head -1 | awk '{print $1}')
VOLUME="/Volumes/$APP_NAME $VERSION"
sleep 2

# --- Let Finder write .DS_Store (icon positions + icon cache) ---
echo "Configuring via Finder..."
osascript <<APPLESCRIPT
tell application "Finder"
  tell disk "$APP_NAME $VERSION"
    open
    set current view of container window to icon view
    set toolbar visible of container window to false
    set statusbar visible of container window to false
    set bounds of container window to {200, 120, 780, 430}
    set theOpts to icon view options of container window
    set arrangement of theOpts to not arranged
    set icon size of theOpts to 128
    set position of item "$APP_NAME.app" of container window to {160, 175}
    set position of item "Applications" of container window to {420, 175}
    set position of item "README.txt" of container window to {290, 320}
    close
    open
    update without registering applications
    delay 3
  end tell
end tell
APPLESCRIPT

# Hide system files created by macOS during RW mount
for f in .fseventsd .Spotlight-V100 .Trashes; do
  [ -e "$VOLUME/$f" ] && chflags hidden "$VOLUME/$f" 2>/dev/null || true
done

sync

# --- Unmount ---
echo "Unmounting..."
hdiutil detach "$DEVICE"

# --- Convert to compressed ---
echo "Building final DMG..."
hdiutil convert "$TMP_DMG" -format UDZO -imagekey zlib-level=9 -o "$OUT"
rm -f "$TMP_DMG"

echo ""
echo "Done: $OUT"
