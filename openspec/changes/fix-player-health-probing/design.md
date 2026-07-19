## Context

`ChannelListViewModel.probeCurrentCountry()` kicks off up to 8 concurrent `StreamProber.isAlive` GETs for every unprobed channel in the selected country whenever the country filter changes, and only cancels on the *next* filter change. Nothing ties this task to the user's current selection: if the user selects and plays a channel whose probe is still in flight, `AVPlayer` can succeed while the independent probe GET (6s timeout, ephemeral session, ordinary HTTP GET against the manifest — not an HLS client) times out or gets rate-limited moments later, calling `healthStore.markFailed`. Since `showOnlyWorkingChannels` defaults to `true`, the channel disappears from `filteredChannels` while it may still be playing. `PlayerViewModel.handleStatusChange` only calls `markFailed` on `.failed`; nothing calls `markWorking` on `.readyToPlay`, so a real, successful playback has no way to protect the channel from a later probe result.

Separately, the player (`PlayerView`, macOS `NSViewRepresentable` around `AVKit.AVPlayerView`) sits in the third pane of a `NavigationSplitView` with no expand/fullscreen control wired up.

## Goals / Non-Goals

**Goals:**
- A channel that is currently selected/playing (or has successfully played earlier this session) can't be hidden by a background probe.
- A single transient network failure (probe, catalog fetch) doesn't permanently blacklist a channel or fail a fetch — retry with backoff first.
- The player can be expanded to fill the screen via a real, discoverable control.

**Non-Goals:**
- Multi-source stream fallback (e.g. official broadcaster URLs) — separate future proposal.
- Changing the probe's detection method (still a manifest GET, not a full HLS handshake) — out of scope, just making it less trigger-happy and less racy.
- iOS/tvOS support — app is macOS-only today.

## Decisions

- **Exempt the selected channel from probing, and re-probe it last.** `probeCurrentCountry()` builds its target list excluding `selectedChannel?.id`. If the user deselects or switches away from a channel that was exempted, it gets probed on the next `probeCurrentCountry()` run (triggered by filter change) like any other unprobed channel. This directly kills the race without needing cross-task cancellation plumbing.
- **`PlayerViewModel` calls `healthStore.markWorking(channelID)` on `.readyToPlay`.** This is the authoritative signal — an actual AVPlayer HLS session succeeded, which is strictly stronger evidence than a manifest GET. Once marked working from playback, it stays working until a *later playback* fails (probes no longer act on the selected channel per the point above, so they can't undo it while selected; after deselection a probe could still mark it failed on a genuinely dead stream, which is correct).
- **Retry with backoff (2 attempts, short fixed delay e.g. 500ms) added in `StreamProber.isAlive` and `ChannelService`'s catalog fetch**, rather than a generic retry wrapper — the two call sites have different failure semantics (probe returns `Bool`, fetch throws) and there are only two of them, so a shared abstraction isn't justified yet.
- **Fullscreen via native macOS window fullscreen, not a custom overlay.** Add a toolbar/button action that calls `NSWindow.toggleFullScreen(_:)` on the player's window, and ensure the window's `collectionBehavior` includes `.fullScreenPrimary` (set once at window setup). This reuses the OS's own fullscreen animation/menu-bar-hiding behavior instead of building a bespoke maximize state, and keeps `AVPlayerView`'s own transport controls working unmodified.

## Risks / Trade-offs

- [Exempting the selected channel from probing means a dead-on-arrival stream the user manually picks won't be flagged until they play it] → acceptable: `PlayerViewModel` already surfaces a `.failed` playback state and calls `markFailed` itself in that case, so the channel still gets correctly flagged, just via the playback path instead of the probe path.
- [Fixed-delay retry adds latency to the worst case (still-dead channel) probe/fetch path] → capped at 2 attempts with a short delay so the added worst-case latency is small (~500ms) relative to existing 6-10s timeouts.
- [`NSWindow.toggleFullScreen` fullscreens the whole app window, not just the player] → acceptable and matches standard macOS video-app behavior (e.g. QuickTime Player); a custom in-pane maximize was considered and rejected as more code for a worse, non-standard result.

## Migration Plan

No data migration. Session-scoped in-memory state only; behavior takes effect immediately on next app launch. No feature flag needed — this is a bug fix to existing, already-shipped behavior.
