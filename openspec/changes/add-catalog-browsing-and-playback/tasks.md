## 1. Catalog data models

- [x] 1.1 Define `Codable` DTOs matching `iptv-org/api` shapes for `channels.json`, `streams.json`, `countries.json`, `categories.json`
- [x] 1.2 Extend `Channel` (or add related types) to carry stream URL, country, and category info needed by browsing/playback
- [x] 1.3 Write the join logic that merges the four fetched arrays into `[Channel]`, keeping channels with no matching stream and skipping malformed entries

## 2. Catalog fetching service

- [x] 2.1 Implement `IPTVOrgChannelService: ChannelService` using `URLSession` async/await, fetching all four endpoints concurrently with `async let`
- [x] 2.2 Add in-memory caching so repeated calls within a session don't refetch
- [x] 2.3 Propagate fetch/decode failures as a typed error the view model can distinguish from "empty catalog"
- [x] 2.4 Wire `IPTVOrgChannelService` as the default in `ChannelListViewModel`, replacing `PlaceholderChannelService`

## 3. Channel browsing UI

- [x] 3.1 Add loading and error (with retry) states to `ChannelListViewModel` and reflect them in `ContentView`
- [x] 3.2 Add country and category filter state to the view model and corresponding filter controls in the UI
- [x] 3.3 Add search-by-name text field wired to a case-insensitive filter on the displayed list
- [x] 3.4 Confirm channel selection flows through to the detail/playback area (already partially wired via `selectedChannel`)

## 4. Stream playback

- [x] 4.1 Add a `PlayerViewModel` (or extend the existing selection state) with `idle`/`loading`/`playing`/`failed(Error)`/`unavailable` states
- [x] 4.2 Build `PlayerView` wrapping `AVPlayerView` via `NSViewRepresentable`, driven by the current channel's stream URL
- [x] 4.3 Wire channel selection changes to stop current playback and start loading the newly selected stream
- [x] 4.4 Show "stream unavailable" state for channels with no stream URL, without invoking the player
- [x] 4.5 Surface AVPlayer loading/failure events (e.g. via KVO/`NotificationCenter` or status observation) into the loading/error states

## 5. Manual verification

- [x] 5.1 `swift build` succeeds with no warnings under Swift 6 strict concurrency — confirmed clean
- [ ] 5.2 Manually run via `swift run`: catalog loads, filters/search work, at least one known-good HLS channel plays audio/video — pending user verification (see run instructions)
- [ ] 5.3 Manually verify error paths: airplane mode / no network on launch, and selecting a channel with a dead stream URL — pending user verification
