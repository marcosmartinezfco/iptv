# iptv

A native macOS IPTV client built with SwiftUI and AVKit.

Channel catalog data is sourced from the [iptv-org](https://github.com/iptv-org/iptv) project.

## Requirements

- macOS 14+
- Swift 6 toolchain (Xcode Command Line Tools or full Xcode)

## Development

```bash
swift build
swift run
```

> Note: XCTest/Swift Testing require full Xcode (not just Command Line Tools), so there's
> no test target yet. Add one back once Xcode is installed.

> **Native (Spaces) window fullscreen — green traffic light / Cmd+Ctrl+F — only works
> when the app is launched as a real `.app` bundle via LaunchServices.** Under plain
> `swift run` macOS silently declines the transition (even with a bundle identity
> embedded in the binary); the green button falls back to zoom. Use `Scripts/run-app.sh`
> when you want that; it wraps the binary in a minimal `.app` and launches it with `open`:
>
> ```bash
> Scripts/run-app.sh          # debug build
> Scripts/run-app.sh release  # release build
> ```
>
> The player's own expand button doesn't depend on any of this — it fills the screen
> manually (window resize + auto-hidden menu bar/Dock), so it works under both launch
> modes. `Supporting/Info.plist` is embedded into the binary's `__TEXT,__info_plist`
> section at link time so `swift run` and the bundled app share one preferences domain.

## Releases

Pushing a tag matching `v*` (e.g. `v0.1.0`) triggers `.github/workflows/release.yml`,
which builds a release configuration, packages it as `IPTV-<version>.zip` (a zipped
`.app` bundle), and publishes a GitHub Release with that artifact attached and
auto-generated release notes. To cut a release:

```bash
git tag v0.1.0
git push origin v0.1.0
```

The release build is **unsigned** (no Apple Developer account configured) — macOS
Gatekeeper will show an "unidentified developer" warning on first launch. Right-click
the app → Open once to bypass it; this is a one-time step per machine.

To build the same packaged artifact locally without cutting a release, use
`Scripts/package-app.sh <configuration> <version> <output-path>` — the release
workflow and `Scripts/run-app.sh` (see above) both call this script under the hood.

## Project layout

```
Sources/IPTV/
  App.swift          # app entry point
  Views/              # SwiftUI views
  ViewModels/          # @Observable view models
  Models/             # data models
  Services/           # networking / data sources
Tests/IPTVTests/
```

## Status

Early scaffolding. See `openspec/` for planned changes once the OpenSpec workflow is set up.
