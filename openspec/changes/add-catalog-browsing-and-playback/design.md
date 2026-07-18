## Context

The app currently ships a SwiftPM (no Xcode project) SwiftUI scaffold: `Channel` model, a `ChannelService` protocol with a placeholder implementation, an `@Observable @MainActor` `ChannelListViewModel`, and a `NavigationSplitView` shell. Swift 6 strict concurrency is on. There is no full Xcode install available in this environment (Command Line Tools only) — no XCTest/Swift Testing, no `.xcodeproj`, no Interface Builder previews. This constrains tooling choices below.

## Goals / Non-Goals

**Goals:**
- Real catalog data from iptv-org, decoded into typed models.
- Browse/filter/search that data in the existing list UI.
- Play a selected channel's stream with AVKit, with visible loading/error states.

**Non-Goals:**
- On-disk caching/persistence of the catalog (in-memory per session only).
- Favorites, EPG/program guide, recording, multi-window, or Picture-in-Picture.
- Automated tests (no XCTest/Swift Testing available without full Xcode — tracked as a follow-up once Xcode is installed, not blocking this slice).
- Handling every iptv-org stream protocol variant (RTMP, UDP) — HLS (`.m3u8`) only for v1; non-HLS streams are marked unavailable rather than special-cased.

## Decisions

**Data source: `iptv-org/api` static JSON, not the `iptv-org/iptv` M3U/CSV files.**
The `api` repo publishes pre-joined, versioned JSON (`channels.json`, `streams.json`, `countries.json`, `categories.json`) via GitHub Pages at `https://iptv-org.github.io/api/`. This avoids writing an M3U/CSV parser and avoids GitHub API rate limits (it's static file hosting, not the GitHub API). Alternative considered: cloning/parsing `iptv-org/iptv`'s `.m3u` playlists directly — rejected for this slice, more parsing work for no functional gain; can revisit if we need data the `api` JSON doesn't expose.

**Networking: plain `URLSession` async/await, no third-party HTTP/JSON library.**
Four static JSON fetches with `Codable` decoding doesn't justify a dependency. Keeps `Package.swift` dependency-free, which matters given the constrained toolchain (SwiftPM must resolve/build any dependency without Xcode's help).

**Catalog join happens client-side after fetch.**
`channels.json`, `streams.json`, `countries.json`, `categories.json` are separate arrays keyed by id (e.g. `channel.id` ↔ `stream.channel`). `ChannelService` fetches all four concurrently (`async let`) and joins them into a single `[Channel]` in memory. A channel with no matching stream entry is kept but marked as unavailable for playback rather than dropped, so browsing/search still surfaces it.

**`ChannelService` stays a protocol; the real implementation is `IPTVOrgChannelService` (or similar), replacing `PlaceholderChannelService` as the default.**
Preserves testability once XCTest is available later, and keeps the view model decoupled from the data source.

**Playback: `AVPlayer` wrapped in `NSViewRepresentable` (`AVPlayerView`), not raw `AVKit` SwiftUI APIs.**
`AVKit`'s `VideoPlayer` SwiftUI view exists but `AVPlayerView` (AppKit) gives more control over controls/error surfacing on macOS. Wrap it once in a small `PlayerView` so the SwiftUI layer only deals with a `Channel?`/loading/error state, not AVFoundation directly.

**Error/loading state: a simple enum on the playback view model (`idle`/`loading`/`playing`/`failed(Error)`), not a generic `Result`/`Loadable` abstraction.**
Only one thing loads at a time (the selected channel's stream); a generic loading-state type would be premature for a single use site.

## Risks / Trade-offs

- [Many public IPTV streams are unreliable/dead] → Surface a clear "stream unavailable" state per channel rather than a silent spinner; don't block browsing on stream health checks (no pre-flight validation of all streams — that would mean checking thousands of URLs).
- [No on-disk cache means a slow/failed catalog fetch blocks the app every launch] → Show a retry affordance on fetch failure; acceptable for this slice since offline use isn't a goal yet.
- [No automated tests until Xcode is installed] → Keep `ChannelService` and the join logic in small, manually-reviewable pure functions so correctness is checkable by inspection; revisit testing once tooling allows.
- [iptv-org data is community-maintained and can change shape] → Decode defensively (optional fields where the source allows nulls) so a handful of malformed entries don't crash catalog decoding entirely.

## Open Questions

- None blocking — revisit persistence/testing/EPG scope in future changes once this slice is in place.
