## Why

The repo currently has a bare SwiftUI/AVKit scaffold with no real data or playback — `ChannelService` is a stub returning an empty list. There is no usable app yet. This change delivers the smallest end-to-end vertical slice: pull real channel data from iptv-org, let the user browse/filter it, and play a selected stream. Every later feature (favorites, EPG, search refinements) builds on this foundation, so it needs to land first.

## What Changes

- Fetch the iptv-org catalog (channels, streams, countries, categories) from the public `iptv-org/api` JSON endpoints over HTTPS and decode it into the existing `Channel` model (extended as needed).
- Replace `PlaceholderChannelService` with a real `URLSession`-backed implementation; keep the protocol so it stays swappable/testable.
- Cache the fetched catalog in memory for the app session (no on-disk persistence yet — refetch on relaunch).
- Build out channel browsing UI: list grouped/filterable by country and category, plus text search, using the existing `NavigationSplitView` shell.
- Integrate `AVKit`/`AVPlayer` playback for the selected channel's stream URL, with loading and error states surfaced in the UI (many public IPTV streams are flaky or dead).
- **BREAKING**: none — this is greenfield, nothing currently depends on the placeholder behavior.

## Capabilities

### New Capabilities
- `channel-catalog`: fetching, decoding, and in-memory caching of the iptv-org channel/stream/country/category data.
- `channel-browsing`: list UI with search and filter by country/category, channel selection.
- `stream-playback`: AVKit-based playback of a selected channel's stream, with loading/error/unavailable states.

### Modified Capabilities
(none — no existing specs yet)

## Impact

- Affected code: `Sources/IPTV/Services/ChannelService.swift`, `Sources/IPTV/Models/Channel.swift`, `Sources/IPTV/ViewModels/ChannelListViewModel.swift`, `Sources/IPTV/Views/ContentView.swift`; adds a new player view and view model.
- New dependency: none required — `URLSession` and `AVKit` are system frameworks, no third-party packages needed for this slice.
- External dependency: network calls to `iptv-org.github.io/api/*.json` (public, unauthenticated, no rate-limit key needed).
- No persistence/storage changes yet (no Core Data/SwiftData in this slice).
