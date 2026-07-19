#!/usr/bin/env bash
# Builds IPTV and launches it as a proper .app bundle instead of via `swift run`.
#
# `swift run` launches a bare executable with no Info.plist and no bundle
# identifier. macOS's window manager relies on that to grant a process
# certain window-manager features (fullscreen/Spaces transitions among
# them) - without it, `NSWindow.toggleFullScreen` and even the native
# green-button fullscreen silently do nothing. Wrapping the built binary
# in a minimal .app bundle and launching it with `open` gives the process
# a real bundle identity, which restores that behavior.
set -euo pipefail

CONFIG="${1:-debug}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="IPTV"
BUILD_DIR="$ROOT/.build/$CONFIG"
APP_BUNDLE="$ROOT/.build/$APP_NAME.app"

echo "Building ($CONFIG)..."
swift build --configuration "$CONFIG" --package-path "$ROOT"

echo "Packaging $APP_BUNDLE..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.marcosmartinezfco.iptv</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>14.0</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSApplicationCategoryType</key>
    <string>public.app-category.entertainment</string>
</dict>
</plist>
PLIST

echo "Launching $APP_BUNDLE..."
open "$APP_BUNDLE"
