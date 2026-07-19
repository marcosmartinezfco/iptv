#!/usr/bin/env bash
# Builds IPTV, packages it as a .app bundle (see Scripts/package-app.sh), and
# launches it via `open` — needed for native OS (Spaces) window fullscreen,
# which macOS only grants to Launch-Services-launched bundles.
set -euo pipefail

CONFIG="${1:-debug}"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_BUNDLE="$ROOT/.build/IPTV.app"

"$ROOT/Scripts/package-app.sh" "$CONFIG" "0.0.0-dev" "$APP_BUNDLE"

echo "Launching $APP_BUNDLE..."
open "$APP_BUNDLE"
