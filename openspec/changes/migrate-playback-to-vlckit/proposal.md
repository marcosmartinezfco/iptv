## Why

`AVPlayer`/AVFoundation rejects a meaningful slice of the `iptv-org` catalog outright — non-standard HLS variants, odd MPEG-TS muxing, and other stream shapes that free/community IPTV sources commonly produce. VLC's engine (libVLC) is built specifically to tolerate exactly this kind of malformed/non-standard media and handles a much broader set of container/codec/protocol combinations. Swapping the playback engine to VLCKit should reduce genuine playback failures (as opposed to the probe/health-state false-negatives already fixed) — channels that are actually broken in AVPlayer but would play fine elsewhere.

## What Changes

- Replace `AVPlayer`/`AVPlayerItem` in `PlayerViewModel` with VLCKit's `VLCMediaPlayer`.
- Replace `AVPlayerView` (both the main pane and the fullscreen presenter) with VLCKit's video rendering view, driven by our own minimal custom transport UI rather than AVKit's floating controls — VLCKit doesn't provide an equivalent all-in-one control surface.
- Add VLCKit as a dependency. **This needs a spike first** (task 1): VLCKit's SPM story is less established than the existing Nuke/Shimmer/Pow dependencies, and its LGPL license requires dynamic (not static) linking to stay compliant when we distribute compiled binaries via GitHub Releases — both need confirming before committing to the rest of the migration.
- **BREAKING (behavior)**: Picture-in-Picture and AVKit's native fullscreen toggle are AVKit-specific and have no VLCKit equivalent — this migration drops them for now rather than reimplementing from scratch. The custom stream-fullscreen window/Esc handling built for `StreamFullScreenPresenter` is kept, just re-pointed at the VLCKit view.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `stream-playback`: playback engine changes from AVPlayer to VLCKit; loading/failed/unavailable states and health-store integration behave the same from the user's perspective; Picture-in-Picture requirement is removed (AVKit-specific, no VLCKit equivalent); fullscreen requirement's "native OS toggle button" detail is removed since it was AVKit's own control, while the app's own expand/fullscreen control (toolbar button, dedicated fullscreen window) is unaffected and stays working.

## Impact

- `Package.swift` — add VLCKit dependency (pending spike outcome on integration method: SPM binary target vs. other)
- `Sources/IPTV/ViewModels/PlayerViewModel.swift` — swap `AVPlayer`/`AVPlayerItem` for `VLCMediaPlayer`, map VLC's state/event model onto the existing `PlaybackState` enum
- `Sources/IPTV/Views/PlayerView.swift` — swap `AVPlayerContainerView` for a VLCKit video view wrapper; add minimal custom transport controls (mute at minimum; live TV doesn't need scrubbing)
- `Sources/IPTV/Views/StreamFullScreenPresenter.swift` — re-point at the VLCKit view instead of a second `AVPlayerView`; drop the `allowsPictureInPicturePlayback`/`allowsMagnification` AVKit-specific lines
- License compliance: LGPL notice + source-availability link needed somewhere discoverable (README or in-app), dynamic linking only
