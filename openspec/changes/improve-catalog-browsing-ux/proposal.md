## Why

The catalog browsing/playback slice shipped a functionally complete but visually bare app: a flat `Text`-only channel list, two filter dropdowns, a full-screen spinner while loading, and no way to tell a live channel from a dead one until you click it and watch it fail. The user wants this to read as a real IPTV app rather than "basic click and play" before adding further features — this change delivers that baseline UX plus finishes the deferred error-path work (task 5.3) from the prior change by turning dead-stream handling into a first-class, testable behavior instead of a manual check.

## What Changes

- Rebuild channel browsing as a proper sidebar: channels grouped into sections by category or country instead of only filterable via dropdowns, keeping the existing `.searchable` search bar integrated into the new layout.
- Display each channel's logo (already present in the joined `Channel` model via iptv-org's `logo` field, currently unused in UI) in list rows, loaded via a third-party SwiftPM async image/caching library (candidate: Nuke/NukeUI) rather than hand-rolled `AsyncImage` caching.
- Replace the full-screen `ProgressView` loading state with skeleton/shimmer placeholder rows (candidate: SwiftUI-Shimmer or equivalent SwiftPM package) so the catalog view never looks empty while fetching.
- Track stream playback failures in memory for the current app session (channel id → failed, cleared on relaunch — streams can come back online, so no on-disk persistence) and add a "Show only working channels" / "Show all channels" toggle to the browsing UI that filters using this session-scoped failure state.
- **BREAKING**: none — additive UI/UX change over the existing `channel-browsing` and `stream-playback` capabilities; no existing API or data contract changes.

## Capabilities

### New Capabilities
(none — this change enhances existing capabilities, it doesn't introduce a new domain)

### Modified Capabilities
- `channel-browsing`: display SHALL change from a flat list to sections grouped by category/country; list rows SHALL show the channel logo; the loading state SHALL show skeleton placeholders instead of a spinner; a working-channels-only filter toggle SHALL be added.
- `stream-playback`: the system SHALL track, in memory for the current session only, which channels' streams have failed to play, and expose that state for the browsing UI's filter toggle.

## Impact

- Affected code: `Sources/IPTV/Views/ContentView.swift` (sidebar/list rewrite), `Sources/IPTV/ViewModels/ChannelListViewModel.swift` (grouping, working-only filter), `Sources/IPTV/ViewModels/PlayerViewModel.swift` (surface failure back to a shared/session store), new views for channel rows/skeleton placeholders, possibly a new lightweight `StreamHealthStore`-style session object.
- New dependencies: at least one third-party SwiftPM package for async image loading/caching, and one for skeleton/shimmer loading placeholders — exact packages to be justified in `design.md`. First third-party dependencies in this repo; `Package.swift` changes accordingly.
- No persistence/storage changes — dead-stream tracking is explicitly in-memory/session-only per user decision.
- Also finishes deferred manual verification (former task 5.3 from `add-catalog-browsing-and-playback`): no-network-on-launch and dead-stream-selection behavior, now folded into this change's own task list and exercised through the new working-only toggle rather than as a one-off manual check.
