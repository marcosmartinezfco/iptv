## Context

`CatalogJoin.join` reduces iptv-org's `streams.json` to one URL per channel via `uniquingKeysWith: { first, _ in first }` (`CatalogJoin.swift:13-16`), so multi-source data the app already downloads is discarded. `Channel.streamURL: URL?` bakes the single-source assumption into the model, `PlayerViewModel.play` makes one attempt against it, and a failure immediately calls `healthStore.markFailed(channelID)` — channel-level state derived from a single URL's fate. `StreamProber` likewise probes the one kept URL. There is no programme/EPG data anywhere in the app; iptv-org publishes companion guide tooling (`iptv-org/epg`) and various hosted XMLTV feeds exist.

## Goals / Non-Goals

**Goals:**
- A channel with any working source plays; only a channel with no working source is marked failed for the session.
- Official broadcaster URLs (curated, starting with Spanish public TV) outrank community-scraped URLs.
- The user can see what's currently airing on a channel wherever guide data exists.
- Wider channel coverage if (and only if) the extra-catalog spike shows real net-new channels with a sane dedupe story.

**Non-Goals:**
- Movies/VOD in any form (see proposal — pirate aggregators refused; legitimate Jellyfin-style integration is a separate future proposal).
- Full guide UI (timeline grid, upcoming programmes, reminders) — this change is "now playing" text only; a richer guide can build on the same `program-guide` capability later.
- Per-source user selection UI ("choose source 2 of 5") — failover is automatic; manual source picking is future work if wanted.
- Recording/timeshift.

## Decisions

- **`Channel.streamSources: [URL]` replaces `streamURL: URL?`, ordered by priority: official overlay first, then `streams.json` order.** An empty array is the "not playable" state (today's `nil`). Rationale: ordering encodes priority with zero extra machinery, and the join site is the single place that builds it.
- **Failover lives in `PlayerViewModel`, not a new layer.** On `.failed` for source *N*, it advances to *N+1* on the same channel and replays; `markFailed` fires only when the list is exhausted; `markWorking` on first success. Rationale: the view model already owns the play/fail state machine and the health-store calls; a separate "source manager" would be indirection with one caller. The probe keeps probing only the top-priority source — it's a cheap liveness signal, and false "dead" marks are already prevented by the playback path outranking probe results (established in fix-player-health-probing).
- **Official streams are a curated static map in-repo (à la `BroadcastOrder`), not a fetched source.** A handful of hand-verified URLs beats building a sync mechanism for a list that changes rarely; contributions extend it via PR. Seed: RTVE channels (La 1, La 2, 24h, Teledeporte, Clan).
- **Extra catalogs and EPG source are both spike-gated, and the spikes are tasks inside this change rather than pre-work.** For catalogs: Free-TV/IPTV (GitHub) is the main candidate; adoption requires the spike to show meaningful channels not already in iptv-org plus dedupe workable via channel id/name+country matching — if it doesn't, the requirement is dropped at archive time rather than forced. For EPG: candidates are hosted XMLTV endpoints vs. consuming iptv-org/epg outputs; decision criteria are: no server-side scraping infrastructure required on our side, coverage for the user's pinned countries (Spain first), and a format parseable without heavyweight dependencies (XMLTV is plain XML — `XMLParser` suffices).
- **EPG data is fetched lazily per visible country, cached in memory for the session, refreshed on a coarse interval (e.g. on country switch or hourly)** — matching the catalog's existing session-cache philosophy; no disk persistence.

## Risks / Trade-offs

- [Failover multiplies worst-case channel-start latency (N timeouts before failure)] → cap attempts (e.g. first 3 sources) and keep the existing per-attempt timeout; surface "trying another source…" in the loading state so it doesn't look frozen.
- [Official URLs can rot too] → they're ordinary members of the ordered source list — if one fails, failover proceeds into the community URLs; a stale overlay entry degrades gracefully rather than breaking a channel.
- [Two catalogs merged badly could produce duplicate channels in the grid] → the spike's dedupe criteria are a gate, not an aspiration; if dedupe confidence is low the second catalog simply isn't merged.
- [EPG feeds are large (all-channels XMLTV can be tens of MB)] → fetch per-country feeds where the chosen source offers them, or filter during streaming parse; only "now/next" is kept in memory, not full schedules.
- [Model change `streamURL` → `streamSources` touches every consumer] → mechanical and compiler-enforced; no persistence format exists to migrate (catalog is session-cached in memory only).

## Migration Plan

Model change first (compiler drives the fan-out), then failover, then overlay, then EPG; the extra-catalog spike can run in parallel with any of it. Each lands as ordinary commits on one change branch, PR'd once per this repo's workflow. No stored data to migrate. Rollback = revert the PR.

## Open Questions

- Which hosted EPG source has reliable Spanish coverage (spike answers this).
- Whether Free-TV/IPTV adds enough beyond iptv-org to justify the merge complexity (spike answers this).
