## Context

Playback today is entirely AVFoundation: `PlayerViewModel` wraps `AVPlayer`/`AVPlayerItem` and observes `.status` via KVO to drive a `PlaybackState` enum (`idle`/`loading`/`playing`/`failed`/`unavailable`) that also feeds `StreamHealthStore` (`markWorking`/`markFailed` on success/failure). Two views embed `AVPlayerView` today: `PlayerView`'s main pane and `StreamFullScreenPresenter`'s dedicated borderless fullscreen window (built last change specifically to route around AVKit/Spaces-fullscreen limitations — that windowing shell is independent of AVKit and doesn't need to change here). AVKit gives us, for free: floating transport controls, a native fullscreen toggle, Picture-in-Picture, and trackpad pinch-to-zoom.

VLCKit (libVLC's Objective-C/Swift-friendly wrapper, published by VideoLAN/Videolabs) exposes `VLCMediaPlayer` (playback engine, event-based rather than KVO) and `VLCVideoView`/`NSView`-based rendering, but does **not** provide floating transport chrome, a fullscreen toggle, or PiP — those are AVKit conveniences with no VLCKit equivalent. Any UI those provided has to be either custom-built or dropped.

## Goals / Non-Goals

**Goals:**
- Channels that fail to play in AVPlayer due to non-standard stream shapes (not due to the channel actually being dead) play successfully via VLCKit.
- `PlaybackState` and `StreamHealthStore` integration behave identically from the app's perspective — this is an engine swap, not a rewrite of the playback state model.
- The custom stream-fullscreen window (`StreamFullScreenPresenter`) and its Esc handling keep working, now hosting a VLCKit view instead of a second `AVPlayerView`.
- Stay LGPL-compliant: dynamic linking only, license notice included.

**Non-Goals (this change):**
- Feature parity with AVKit's floating controls, native fullscreen toggle, or Picture-in-Picture. PiP has no VLCKit equivalent and is dropped. A minimal custom control (mute toggle at minimum — live TV doesn't need scrubbing/seek) replaces the floating bar; anything beyond that is future work.
- Multi-source/fallback stream URLs — separate, already-discussed future proposal.
- Windows/Linux — this app is macOS-only.

## Decisions

- **Spike first (task 1), before touching `PlayerViewModel`.** VLCKit's SPM support is less battle-tested than this project's existing dependencies (Nuke, Shimmer, Pow all have clean SPM releases). The spike must confirm: (a) a working SPM integration path — either a proper Swift package or a `.binaryTarget` pointing at VLCKit's distributed `.xcframework` — and (b) that dynamic linking is actually what results (not static), since that's the LGPL compliance requirement. If neither works cleanly, this migration is blocked and needs a different plan (e.g. vendoring a prebuilt framework manually, which is a bigger scope change to how this project is built and distributed) — that decision explicitly comes back to the app owner before proceeding further, not something to route around silently.
- **Map VLCKit's event model onto the existing `PlaybackState` enum, don't introduce a new one.** `VLCMediaPlayer` reports state via delegate callbacks (`mediaPlayerStateChanged`) rather than KVO, but the mapping to `idle`/`loading`/`playing`/`failed` is direct enough that `PlayerViewModel`'s public shape (and therefore `PlayerView`'s consumption of it) doesn't need to change — only the private implementation swaps.
- **Build a minimal custom transport bar rather than trying to replicate AVKit's.** Live TV channels don't have a timeline to scrub, so the actual gap versus AVKit's floating controls is small: mute/volume and the existing custom fullscreen/expand button (already built, engine-independent). No native fullscreen toggle inside the video itself — that was always an AVKit affordance layered on top of Spaces fullscreen, which the app's own `StreamFullScreenPresenter` already routes around anyway.
- **Drop PiP for this change rather than reimplementing it.** Reimplementing floating-window PiP from scratch is a meaningfully sized project on its own (a persistent floating NSWindow with its own lifecycle, always-on-top behavior, drag-to-reposition) — out of scope here. Flagged as a known regression to the app owner, not silently dropped without mention.
- **Dynamic linking, LGPL notice.** VLCKit/libVLC is LGPL v2.1. Distributing a compiled `.app` (as this project's release workflow now does) while statically linking an LGPL library removes the user's ability to relink against a modified version of that library, which the LGPL requires you to preserve — so VLCKit must be linked as a dynamic framework embedded in the bundle, and a license notice (crediting VideoLAN, linking to VLC's source) needs to live somewhere discoverable (README, and/or an in-app "About" if one gets built later).

## Risks / Trade-offs

- [VLCKit SPM integration may not be clean] → mitigated by making it an explicit spike (task 1) with a go/no-go decision point before any further work, rather than discovering this mid-migration.
- [Losing PiP and AVKit's native fullscreen toggle is a real, user-visible regression] → acceptable given the reliability upside is the actual goal here, but explicitly called out rather than silently dropped; the app's own custom fullscreen (toolbar button + dedicated window) is unaffected and remains the primary fullscreen path regardless.
- [LGPL compliance is easy to get subtly wrong] → mitigated by making dynamic linking a hard requirement verified in the spike, not an afterthought.
- [VLCKit adds real binary size / app size] → acceptable trade-off for the reliability goal; not a hard constraint for this app.

## Migration Plan

Spike (task 1) gates everything else — if it fails, stop and bring the blocker back to the app owner rather than picking a workaround unilaterally. If it succeeds: swap `PlayerViewModel`'s internals, then both view sites, verifying manually after each (main pane, then fullscreen presenter) rather than swapping both at once. No data migration; this is pure playback-engine plumbing. Rollback is a straightforward revert (single cohesive PR, no partial/flagged state).
