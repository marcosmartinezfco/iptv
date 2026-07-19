## 1. Stop the health probe from fighting live playback

- [x] 1.1 In `ChannelListViewModel.probeCurrentCountry()`, exclude `selectedChannel?.id` from the probe target list
- [ ] 1.2 Verify a channel selected/played while its country's probe pass is still running is not marked failed by that pass (manual — see note below)
- [ ] 1.3 Verify deselecting/switching away from a channel allows it to be probed normally on the next `probeCurrentCountry()` run (manual)

## 2. Record successful playback as working

- [x] 2.1 In `PlayerViewModel.handleStatusChange`, call `healthStore?.markWorking(currentChannelID)` on `.readyToPlay`
- [ ] 2.2 Verify a channel that plays successfully is not hidden by `showOnlyWorkingChannels` afterward (manual)

## 3. Retry with backoff on transient network failures

- [x] 3.1 Add retry (2 attempts, short fixed backoff) to `StreamProber.isAlive`
- [x] 3.2 Add retry (2 attempts, short fixed backoff) to `ChannelService`'s catalog fetch (`fetchJSON`)
- [ ] 3.3 Verify a single simulated transient failure (timeout/non-2xx) recovers on retry without marking the channel/fetch as failed (manual)
- [x] 3.4 Send a browser/player-like `User-Agent` header on probe requests — some hosts allow real players through but block/rate-limit generic HTTP clients, which was a source of false-dead probes independent of transient network failures

## 4. Fullscreen/expand control on the player

- [x] 4.1 Ensure the app window's `collectionBehavior` includes `.fullScreenPrimary`
- [x] 4.2 Add an expand/fullscreen button to `PlayerView` that calls `NSWindow.toggleFullScreen(_:)` on the player's window
- [ ] 4.3 Verify entering and exiting fullscreen via the control works, and playback continues uninterrupted across the transition (manual)
- [x] 4.4 Fix: capture the hosting `NSWindow` via `viewDidMoveToWindow` instead of a one-shot async read in `makeNSView`, which was racing SwiftUI's view attachment and leaving `window` nil (fullscreen button silently doing nothing)
- [x] 4.5 Fix: `viewDidMoveToWindow` capture still didn't fix the no-op button in practice — replaced with resolving `NSApp.keyWindow`/`NSApp.mainWindow` directly at click time, which can't race since a click can't happen before the window is key
- [x] 4.6 Fix: button was still completely inert (no visual response to clicks) even after 4.5 — root cause was `AVPlayerView`'s own floating-controls hit-testing swallowing clicks across the whole video frame regardless of SwiftUI z-order, since it's a plain sibling NSView overlay, not something SwiftUI ordering controls. Moved the fullscreen control into the window toolbar (`.toolbar` on `PlayerView`), a hit-testing region entirely outside the player's bounds
- [x] 4.7 Fix: even in the toolbar, both the button and native OS fullscreen (green traffic light / Cmd+Ctrl+F) did nothing — confirmed root cause is that `swift run` launches a bare executable with no `.app` bundle/bundle identifier, and macOS silently declines window-manager fullscreen transitions for such a process. Added `Scripts/run-app.sh`, which builds and wraps the binary in a minimal `.app` bundle and launches it via `open`, restoring proper window-manager integration; documented in README
- [x] 4.8 Fix: `NSWindow.toggleFullScreen` fullscreens the whole three-column app window (sidebar + grid included), not the video — not what "make the stream big" meant. Reworked the expand button to collapse `NavigationSplitView` to `.detailOnly` (video fills the window, sidebar/grid hidden) via a `columnVisibility` binding threaded from `ContentView` into `PlayerView`, and still requests real OS fullscreen alongside it as a bonus when supported
- [x] 4.9 Embed `Supporting/Info.plist` into the binary's `__TEXT,__info_plist` section via linker flags in `Package.swift` — gives the `swift run` executable a bundle identity (unifies the preferences domain with the bundled app). Made the player button check the window's actual fullscreen state instead of blindly toggling
- [x] 4.10 Embedded identity turned out NOT to be enough for Spaces fullscreen — macOS only grants it to LaunchServices-launched bundles, so the green button under `swift run` can never do it (OS constraint, documented in README; `Scripts/run-app.sh` remains the way to get it). Reworked the stream-fullscreen button to not depend on the OS at all: window resized to screen bounds + menu bar/Dock auto-hidden + columns collapsed, restoring the saved frame on exit — works identically under both launch modes

## 6. Launch defaults

- [x] 6.1 On launch, when favorite countries exist, auto-select the first favorite (alphabetically) instead of the full global "All Countries" list

## 5. Verification

- [x] 5.1 `swift build` passes (no `Tests/` target exists in this project yet, so `swift test` is a no-op per CI's own check)
- [x] 5.2 `swiftformat --lint` passes; `swiftlint --strict` could not be run in this environment (only Command Line Tools installed, no full Xcode — SourceKit crashes on load). Not caused by this change; CI's macOS runner has full Xcode and should run it fine.
- [ ] 5.3 Manual pass: select a channel in a country with unprobed channels, play it immediately, confirm it stays visible and playing through a full probe pass of that country (manual)
