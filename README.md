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

> **Window-manager features (fullscreen, Spaces) don't work under `swift run`.** It
> launches a bare executable with no `.app` bundle or bundle identifier, and macOS
> silently declines fullscreen transitions for such a process — no error, it just does
> nothing. Use `Scripts/run-app.sh` instead when testing anything fullscreen-related; it
> builds and wraps the binary in a minimal `.app` bundle, then launches it with `open`:
>
> ```bash
> Scripts/run-app.sh          # debug build
> Scripts/run-app.sh release  # release build
> ```

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
