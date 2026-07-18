## 1. Dependencies

- [x] 1.1 Add Nuke/NukeUI to `Package.swift` (pinned version), confirm `swift build` stays clean under Swift 6 strict concurrency
- [x] 1.2 Add a shimmer/skeleton SwiftPM package (e.g. SwiftUI-Shimmer) to `Package.swift`, or implement a small hand-rolled `.shimmering()` modifier if none is a good strict-concurrency fit; confirm clean build either way

## 2. Skeleton loading state

- [x] 2.1 Build a placeholder channel-row view matching the real row's layout (name + logo slot)
- [x] 2.2 Apply the shimmer effect to a stack of placeholder rows and show it in `ChannelListViewModel`'s `.loading` state, replacing the current full-screen `ProgressView`
- [x] 2.3 Confirm the `.failed` (fetch error) and `.loaded` states are unaffected by the new loading state

## 3. Channel logos

- [x] 3.1 Add a channel row view using `NukeUI.LazyImage` (or equivalent) bound to the channel's `logo` URL, with a generic fallback icon for missing/failed logos
- [x] 3.2 Replace the current `Text(channel.name)` row rendering in the channel list with this new row view

## 4. Category-grouped sidebar

- [x] 4.1 Add a computed property to `ChannelListViewModel` that groups `filteredChannels` into category sections (a channel appears in every category section it belongs to)
- [x] 4.2 Rebuild the channel list in `ContentView` as `List` sections keyed by category, using the new row view from 3.1/3.2
- [x] 4.3 Keep the existing `.searchable` search bar and country `Picker` filter working against the grouped display
- [x] 4.4 Remove the now-redundant category `Picker` filter (superseded by category sections)

## 5. Session-scoped dead-stream tracking

- [x] 5.1 Add a `StreamHealthStore` (`@Observable @MainActor`, in-memory `Set<Channel.ID>` of failed channel ids, no persistence)
- [x] 5.2 Own one `StreamHealthStore` instance at the `ContentView`/app level; inject into `PlayerViewModel` and `ChannelListViewModel`
- [x] 5.3 Update `PlayerViewModel` to record a failure into the store when playback transitions to `.failed`
- [x] 5.4 Add a "Show only working channels" toggle to the browsing UI, wired to a filter in `ChannelListViewModel` that excludes channel ids present in the store
- [x] 5.5 Confirm the toggle composes correctly with search/country filters and category grouping (4.1-4.3) — same `filteredChannels` pipeline feeds grouping, all three conditions compose via `&&`

## 6. Manual verification

- [x] 6.1 `swift build` succeeds with no warnings under Swift 6 strict concurrency — confirmed via clean `rm -rf .build && swift build`
- [ ] 6.2 `swift run`: confirm skeleton loading shows on launch, then category-grouped sidebar with logos renders correctly — pending user verification (app launches cleanly; noticed a one-time non-repeating "reentrant operation in its NSTableView delegate" warning at launch, not a crash, worth keeping an eye on but not blocking)
- [ ] 6.3 Select a channel with a dead stream URL; confirm the playback error state shows, then confirm it appears excluded when "Show only working channels" is enabled and reappears when disabled — closes out the deferred error-path verification from `add-catalog-browsing-and-playback` — pending user verification
- [ ] 6.4 Simulate no network on launch (airplane mode); confirm the existing catalog-fetch error/retry state still works correctly with the new skeleton-loading UI in place — pending user verification
- [ ] 6.5 Verify country filter and search still narrow results correctly within the new category-grouped sidebar — pending user verification
