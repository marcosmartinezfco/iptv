## 1. Catalog data models

- [ ] 1.1 Define `Codable` DTOs matching `iptv-org/api` shapes for `channels.json`, `streams.json`, `countries.json`, `categories.json`
- [ ] 1.2 Extend `Channel` (or add related types) to carry stream URL, country, and category info needed by browsing/playback
- [ ] 1.3 Write the join logic that merges the four fetched arrays into `[Channel]`, keeping channels with no matching stream and skipping malformed entries

## 2. Catalog fetching service

- [ ] 2.1 Implement `IPTVOrgChannelService: ChannelService` using `URLSession` async/await, fetching all four endpoints concurrently with `async let`
- [ ] 2.2 Add in-memory caching so repeated calls within a session don't refetch
- [ ] 2.3 Propagate fetch/decode failures as a typed error the view model can distinguish from "empty catalog"
- [ ] 2.4 Wire `IPTVOrgChannelService` as the default in `ChannelListViewModel`, replacing `PlaceholderChannelService`

## 3. Channel browsing UI

- [ ] 3.1 Add loading and error (with retry) states to `ChannelListViewModel` and reflect them in `ContentView`
- [ ] 3.2 Add country and category filter state to the view model and corresponding filter controls in the UI
- [ ] 3.3 Add search-by-name text field wired to a case-insensitive filter on the displayed list
- [ ] 3.4 Confirm channel selection flows through to the detail/playback area (already partially wired via `selectedChannel`)

## 4. Stream playback

- [ ] 4.1 Add a `PlayerViewModel` (or extend the existing selection state) with `idle`/`loading`/`playing`/`failed(Error)`/`unavailable` states
- [ ] 4.2 Build `PlayerView` wrapping `AVPlayerView` via `NSViewRepresentable`, driven by the current channel's stream URL
- [ ] 4.3 Wire channel selection changes to stop current playback and start loading the newly selected stream
- [ ] 4.4 Show "stream unavailable" state for channels with no stream URL, without invoking the player
- [ ] 4.5 Surface AVPlayer loading/failure events (e.g. via KVO/`NotificationCenter` or status observation) into the loading/error states

## 5. Manual verification

- [ ] 5.1 `swift build` succeeds with no warnings under Swift 6 strict concurrency
- [ ] 5.2 Manually run via `swift run`: catalog loads, filters/search work, at least one known-good HLS channel plays audio/video
- [ ] 5.3 Manually verify error paths: airplane mode / no network on launch, and selecting a channel with a dead stream URL
