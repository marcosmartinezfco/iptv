> **OUTCOME: ABANDONED (2026-08-04).** The migration was implemented end-to-end and
> built cleanly, but was reverted before merging: VLCKit 4.0.0-a22 (the newest
> available tag) has a hang bug on macOS — its CoreAudio output module enters an
> infinite device-reconfiguration loop when audio devices appear/disappear (observed
> live, triggered by an iPhone Continuity microphone: `AudioObjectAddPropertyListener
> failed … OSStatus: 1852797029` → "audio device configuration changed, resetting
> cache" → repeat forever), leaving the app unresponsive. No app-level workaround
> exists: VLCKit exposes no API to pin an output device or disable hotplug
> monitoring, no libVLC option covers it, and the known fixes for this bug class
> (debounce/init guards) live inside the native audio backend — fixable only by
> patching and rebuilding libVLC itself. The playback code stays on AVKit. Revisit
> only if a stable (non-alpha) VLCKit 4.x ships with this fixed.
>
> Task statuses below reflect what was actually done before the revert.

## 1. Spike: VLCKit integration (gates everything below)

- [x] 1.1 SPM integration found: VideoLAN's own `videolan/vlckit` repo carries a `Package.swift` on tagged releases (undocumented; alpha `4.0.0-a22`) with a checksum-pinned `binaryTarget` at `download.videolan.org` targeting macOS 10.13+
- [x] 1.2 Dynamic linking confirmed via `otool -L`/`file`: the XCFramework is a dynamic library, SwiftPM wires `@loader_path` rpath + copies `VLCKit.framework` beside the binary — LGPL-compliant
- [x] 1.3 Proof of concept: full implementation built and launched; playback itself was never user-verified because the audio-loop hang surfaced first
- [x] 1.4 Decision point exercised twice: (a) third-party-wrapper-only SPM finding → owner approved proceeding once VideoLAN's own package was found; (b) hang bug + no workaround → owner chose revert

## 2. Playback engine swap (implemented, then reverted)

- [x] 2.1 VLCKit dependency added to `Package.swift` (`exact: "4.0.0-a22"`) — reverted
- [x] 2.2 `PlayerViewModel` swapped to `VLCMediaPlayer` + `VLCMedia`, delegate proxy (`NSObject`-conforming) mapping `VLCMediaPlayerState` onto the existing `PlaybackState` enum; real state cases verified from the framework's own headers (`.nothingSpecial/.opening/.playing/.paused/.stopped/.stopping/.error` — no `.buffering`/`.ended` cases; buffering is a separate delegate callback) — reverted
- [ ] 2.3 `markWorking`/`markFailed` never verified against real playback — the hang preempted testing

## 3. Main player view (implemented, then reverted)

- [x] 3.1 `AVPlayerContainerView` replaced with a `VLCVideoView` wrapper (re-claiming `player.drawable` on every SwiftUI update, since VLC renders to a single drawable — unlike AVPlayer's multi-layer rendering) — reverted
- [x] 3.2 Toolbar mute button added (`player.audio?.isMuted`) — reverted
- [x] 3.3 AVKit-specific lines removed — reverted
- [ ] 3.4 Manual verification preempted by the hang

## 4. Fullscreen presenter (implemented, then reverted)

- [x] 4.1 `StreamFullScreenPresenter` re-pointed at a `VLCVideoView` — reverted
- [ ] 4.2 Manual verification preempted by the hang

## 5. License compliance (implemented, then reverted)

- [x] 5.1 LGPL notice added to README — reverted with the rest
- [ ] 5.2 Release-build packaging check never reached

## 6. Verification

- [x] 6.1 `swift build` and `swiftformat --lint` passed on the VLCKit implementation, and pass again after the revert (working tree back to the exact AVKit code shipped in v0.1.0)
- [ ] 6.2 The comparative channel test never ran — the app hung (infinite CoreAudio device-reconfiguration loop) before playback could be exercised
- [x] 6.3 `openspec validate migrate-playback-to-vlckit --strict` passes
