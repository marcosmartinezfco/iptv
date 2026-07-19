## Why

Channels the user is actively watching (or just successfully watched) can vanish from the sidebar/grid because a background stream-health probe re-checks the same URL via a plain HTTP GET — a different, more failure-prone path than actual AVPlayer/HLS playback — and marks the channel dead on a timeout or rate limit. A successful playback never overrides this, and there's no retry anywhere in the app, so a single flaky request against the free `iptv-org` stream sources permanently hides a channel for the rest of the session. The player also has no way to expand/maximize, leaving it cramped in a small `NavigationSplitView` pane.

## What Changes

- Stop the background health probe from re-checking (or acting on failures for) the channel that is currently selected/playing, so it can't be hidden out from under an active playback.
- Mark a channel as working in the session-scoped health state when its stream successfully starts playing, so a channel that has proven itself this session isn't later hidden by an unrelated probe failure.
- Add basic retry with backoff (e.g. 2 attempts) to the stream-health probe and to catalog/stream fetches, so a single transient network failure doesn't permanently blacklist a channel or fail a fetch.
- Add a fullscreen/expand affordance to the player view so the video can be viewed larger than the fixed detail-pane size.
- On launch, auto-select the first favorite country (alphabetically) instead of the full global channel list, when favorites exist.
- Enable Picture-in-Picture and trackpad pinch-to-zoom on the player, both off by default in a manually-embedded `AVPlayerView`.

## Capabilities

### New Capabilities
(none)

### Modified Capabilities
- `stream-playback`: successful playback now marks the channel as working in session health state; playback area gains a fullscreen/expand control.
- `channel-browsing`: the background stream-health probe SHALL NOT probe the currently selected/playing channel, and probe failures SHALL retry with backoff before marking a channel failed.
- `channel-catalog`: catalog fetch SHALL retry with backoff on a transient failure before surfacing a load failure to callers.
- `channel-browsing`: (additional delta) on launch, the system SHALL select the first favorite country instead of "All Countries" when a favorite exists.

## Impact

- `Sources/IPTV/Services/StreamProber.swift` — add retry/backoff, player-like User-Agent, respect an "exempt currently-playing channel" rule
- `Sources/IPTV/ViewModels/StreamHealthStore.swift` — support `markWorking`
- `Sources/IPTV/ViewModels/ChannelListViewModel.swift` — probe scheduling must skip/pause the selected channel
- `Sources/IPTV/ViewModels/PlayerViewModel.swift` — call `markWorking` on successful playback
- `Sources/IPTV/Views/PlayerView.swift` — fullscreen UI (dedicated borderless fullscreen window, `StreamFullScreenPresenter`), enable PiP/pinch-zoom
- `Sources/IPTV/Views/StreamFullScreenPresenter.swift` — new: presents the stream in a screen-covering borderless window, independent of SwiftUI layout and OS Spaces-fullscreen grants
- `Sources/IPTV/Views/ContentView.swift` — auto-select first favorite country on launch
- `Sources/IPTV/Services/ChannelService.swift` — retry/backoff on catalog fetch
- `Package.swift` / `Supporting/Info.plist` — embed a bundle identity into the `swift run` executable
- `Scripts/run-app.sh` — new: packages and launches a real `.app` bundle, needed for native OS (Spaces) window fullscreen, which macOS only grants to Launch-Services-launched bundles
