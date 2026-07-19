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

## 5. Verification

- [x] 5.1 `swift build` passes (no `Tests/` target exists in this project yet, so `swift test` is a no-op per CI's own check)
- [x] 5.2 `swiftformat --lint` passes; `swiftlint --strict` could not be run in this environment (only Command Line Tools installed, no full Xcode — SourceKit crashes on load). Not caused by this change; CI's macOS runner has full Xcode and should run it fine.
- [ ] 5.3 Manual pass: select a channel in a country with unprobed channels, play it immediately, confirm it stays visible and playing through a full probe pass of that country (manual)
