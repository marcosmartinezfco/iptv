#!/usr/bin/env bash
# Builds IPTV and packages it into a proper .app bundle. Does NOT launch it —
# reusable by both local dev (Scripts/run-app.sh) and CI (release workflow).
#
# `swift run`/a bare executable has no Info.plist and no bundle identifier.
# macOS's window manager relies on that for certain window-manager features
# (fullscreen/Spaces transitions among them) - without it, they silently
# no-op. Wrapping the built binary in a minimal .app bundle gives the process
# a real bundle identity, which restores that behavior.
#
# Usage: package-app.sh [configuration] [version] [output-app-path]
#   configuration    swift build --configuration value (default: debug)
#   version          CFBundleShortVersionString to embed (default: 0.0.0-dev)
#   output-app-path  where to write the .app bundle (default: .build/IPTV.app)
set -euo pipefail

CONFIG="${1:-debug}"
VERSION="${2:-0.0.0-dev}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="IPTV"
APP_BUNDLE="${3:-$ROOT/.build/$APP_NAME.app}"
BUILD_DIR="$ROOT/.build/$CONFIG"

echo "Building ($CONFIG)..."
swift build --configuration "$CONFIG" --package-path "$ROOT"

echo "Packaging $APP_BUNDLE (version $VERSION)..."
rm -rf "$APP_BUNDLE"
mkdir -p "$APP_BUNDLE/Contents/MacOS"
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"

sed "s/__VERSION__/$VERSION/" "$ROOT/Supporting/Info.plist" > "$APP_BUNDLE/Contents/Info.plist"

echo "Packaged $APP_BUNDLE"
