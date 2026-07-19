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

> Fullscreen works under plain `swift run`: `Supporting/Info.plist` is embedded into the
> binary's `__TEXT,__info_plist` section at link time, giving the bare executable a bundle
> identity — without one, macOS silently refuses window-manager fullscreen transitions.
> `Scripts/run-app.sh` additionally wraps the binary in a real `.app` bundle and launches
> it with `open` (proper Dock/app-switcher integration):
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
