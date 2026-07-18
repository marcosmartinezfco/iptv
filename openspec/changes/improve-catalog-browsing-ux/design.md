## Context

`add-catalog-browsing-and-playback` shipped a functionally complete but visually minimal app (see `Sources/IPTV/Views/ContentView.swift`): a flat `Text`-only `List`, two `Picker` filter dropdowns, a full-screen `ProgressView` while the catalog loads, and no channel logos despite the joined `Channel` model already carrying a `logo` URL from iptv-org's `channels.json`. That change also deliberately used zero third-party dependencies. This change is the first to add SwiftPM dependencies, and needs to decide which ones, how session-scoped dead-stream tracking is architected, and how channels are grouped in the new sidebar.

## Goals / Non-Goals

**Goals:**
- Sidebar grouped by category (the primary IPTV browsing mental model — "Sports", "Kids", "News", etc.), with country and search remaining available as filters within/across groups, not as a second grouping axis (avoids combinatorial section explosion).
- Channel logos in list rows via a well-maintained async image/caching SwiftPM library.
- Skeleton/shimmer placeholder rows during initial catalog load via a SwiftPM shimmer library, replacing the full-screen spinner.
- Session-scoped dead-stream tracking (channel id → failed) feeding a "Show only working channels" toggle.
- Preserve the Swift 6 strict-concurrency clean build the prior change established.
- Finish deferred manual verification (no-network-on-launch, dead-stream selection) against the new UI.

**Non-Goals:**
- On-disk persistence of dead-stream state or the catalog itself (explicitly session/in-memory only, per user decision — out of scope for this change).
- Favorites/bookmarks, EPG, "recently watched" — explicitly deferred to a later change.
- Pre-checking stream liveness before the user selects a channel (still discovered on-attempt, per user decision — "just show a clear failed state").

## Decisions

### Grouping: category as primary sidebar axis, country stays a filter
IPTV apps conventionally browse by category (genre) first. Grouping by country as well would require either nested sections (category → country, high complexity for marginal value) or picking one axis — category is more useful for a viewer than country in the common case. Country remains available as a `Picker` filter that narrows within/across category sections, same mechanism as today, just restyled into the new sidebar. **Open question below** if the user wants country promoted to equal footing later.

### Async image loading: Nuke / NukeUI
Candidates considered: `Nuke`/`NukeUI` (kean/Nuke) vs `Kingfisher`. Both are mature and actively maintained. Chose Nuke/NukeUI: native `async`/`await` and Swift 6 strict-concurrency-clean API (matters for this repo's existing clean-strict-concurrency bar), a purpose-built SwiftUI `LazyImage` view with built-in placeholder/failure-image slots (fits the skeleton-loading and dead-logo-URL cases directly), and a smaller dependency surface than Kingfisher's broader feature set (which this app doesn't need — no image processing pipeline, no UIKit-era APIs relevant on macOS).

### Skeleton loading: SwiftUI-Shimmer (or equivalent small SwiftPM shimmer package)
A single-purpose `.shimmering()` view modifier over placeholder-shaped rows (`RoundedRectangle` fills matching the real row layout) is enough — no need for a heavier "skeleton framework." Exact package pinned in `Package.swift` during implementation; if `SwiftUI-Shimmer` (mergesort) turns out unmaintained/incompatible at implementation time, fall back to a ~20-line hand-rolled `AnimatablePausableModifier` rather than pulling a heavier alternative.

### Session-scoped dead-stream tracking: shared `@Observable` health store, not baked into `PlayerViewModel`
`PlayerViewModel` is scoped to "the currently playing channel"; the working/broken toggle needs history across *all* channels attempted this session. Introduce a small `@Observable @MainActor` `StreamHealthStore` (or equivalent name) holding `Set<Channel.ID>` of failed ids, owned at the `ContentView`/app level and injected into both `PlayerViewModel` (to record a failure when playback fails) and `ChannelListViewModel` (to filter when the toggle is on). Keeps `PlayerViewModel`'s existing state machine (`idle`/`loading`/`playing`/`failed`/`unavailable`) unchanged — it just reports out on transition to `.failed`.

## Risks / Trade-offs

- **Third-party dependency risk** (abandonment, Swift 6 concurrency incompatibility introduced by an update) → Mitigation: pin exact versions in `Package.swift`, keep both libraries behind thin usage (a single `LazyImage`-wrapping view, a single `.shimmering()` call site) so swapping libraries later is a small, contained change.
- **Large category sections** (some iptv-org categories have hundreds of channels) → Mitigation: sections are lazily rendered `List` sections (SwiftUI already lazy-loads `List` rows); no eager full-section rendering needed. Revisit collapsible sections only if this proves insufficient.
- **Logo URLs may be slow, missing, or dead** (iptv-org logos are community-contributed, not guaranteed reachable) → Mitigation: `NukeUI.LazyImage` placeholder/failure slots show a generic channel-icon fallback rather than a broken-image state.
- **Session-scoped store adds a new piece of shared state** (vs. the prior change's fully self-contained view models) → Mitigation: keep it minimal (one `Set`, no persistence, no complex API) and scoped to this one cross-cutting concern only.

## Migration Plan

Not a deployed service — this is a local macOS app, so "migration" is implementation sequencing:
1. Add SwiftPM dependencies, confirm `swift build` stays clean under Swift 6 strict concurrency.
2. Build skeleton/shimmer placeholder rows against the existing flat list first (smallest visible win, no data-model changes).
3. Add logo rendering to list rows.
4. Rebuild the sidebar as category-grouped sections, folding in the existing search/country filter.
5. Add `StreamHealthStore`, wire failure recording from `PlayerViewModel`, add the working-only toggle.
6. Manual verification pass (no-network-on-launch, dead-stream selection + toggle behavior) — closes out the deferred task 5.3 work.

Rollback: each step is an independent commit; any step can be reverted without affecting the ones before it, since later steps only add to earlier ones (no step rewrites a prior step's output).

## Open Questions

- Should country ever get promoted to an equal-footing grouping axis (vs. staying a filter within category groups)? Deferred until real usage shows the category-only grouping is insufficient.
- Exact shimmer/skeleton package to pin — left for implementation time in case `SwiftUI-Shimmer`'s maintenance status has changed since this design was written.
