#!/bin/bash
set -e

APP_NAME="Sudoku"
BUILD_DIR="sudoku_app/build/macos/Build/Products/Release"
STAGING="sudoku_app/build/dmg_staging"
OUT="sudoku_app/build/$APP_NAME.dmg"

if [ ! -d "$BUILD_DIR/$APP_NAME.app" ]; then
  echo "Release app not found. Run 'flutter build macos --release' first."
  exit 1
fi

rm -rf "$STAGING"
mkdir -p "$STAGING"

echo "Copying $APP_NAME.app..."
cp -R "$BUILD_DIR/$APP_NAME.app" "$STAGING/$APP_NAME.app"

echo "Creating install script..."
cat > "$STAGING/Install $APP_NAME.command" << 'EOF'
#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP="Sudoku.app"
DEST="/Applications/$APP"

echo ""
echo "=== Sudoku Installer ==="
echo ""

if [ -d "$DEST" ]; then
  echo "Updating existing installation..."
  rm -rf "$DEST"
fi

echo "Copying to /Applications..."
if ! cp -R "$SCRIPT_DIR/$APP" "$DEST" 2>/dev/null; then
  echo "Trying with administrator privileges..."
  sudo cp -R "$SCRIPT_DIR/$APP" "$DEST"
fi

echo "Removing quarantine..."
xattr -cr "$DEST"

echo ""
echo "Done. Launch Sudoku from Applications or Launchpad."
echo ""
read -p "Press Enter to close..."
EOF

chmod +x "$STAGING/Install $APP_NAME.command"

echo "Building DMG..."
rm -f "$OUT"
hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$STAGING" \
  -ov \
  -format UDZO \
  "$OUT"

rm -rf "$STAGING"

echo ""
echo "Done: $OUT"
