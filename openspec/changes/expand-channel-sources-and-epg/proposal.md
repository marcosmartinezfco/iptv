## Why

A channel today lives or dies by a single stream URL, even though iptv-org's `streams.json` frequently lists several URLs per channel — `CatalogJoin` currently keeps the first and discards the rest (`uniquingKeysWith: { first, _ in first }`), so a channel gets marked dead when its *first* URL fails while a working alternative sits unused. Reliability for major channels also shouldn't depend on community-scraped links at all when broadcasters publish official free streams (e.g. RTVE for La 1/La 2). Separately, the catalog is a bare channel list: without programme information the user can't see what's actually on, which is half the point of a TV guide-style app.

Movies/VOD were considered for this change and explicitly excluded: the only "movie API" sources available without licensing (111movie/67movies-style aggregators) redistribute pirated content and will not be integrated; a legitimate path (e.g. a Jellyfin client mode for a self-hosted library) can be its own future proposal.

## What Changes

- Keep **all** stream URLs per channel from `streams.json` (ordered), not just the first; on playback failure, automatically try the next URL before surfacing failure or marking the channel dead in the session health store.
- Add a curated **official-streams overlay**: a small static mapping of channel id → official broadcaster stream URL that takes priority over community-scraped URLs (seeded with Spanish public broadcasters; extensible).
- **Spike** additional open channel catalogs (e.g. Free-TV/IPTV on GitHub) for merging with iptv-org to widen channel coverage, with dedupe by channel id/name — adoption gated on the spike confirming meaningful net-new channels and a workable dedupe story.
- Add an **EPG (programme guide)** integration so channels show what's currently airing (programme title at minimum, in the channel grid and/or player) — source selection (hosted XMLTV feeds vs. iptv-org's EPG tooling) gated on a spike.

## Capabilities

### New Capabilities
- `program-guide`: fetching EPG data and showing the currently-airing programme for channels that have guide data.

### Modified Capabilities
- `channel-catalog`: channels carry an ordered list of stream sources (community + official overlay + optionally additional catalogs) instead of a single optional URL.
- `stream-playback`: playback tries a channel's sources in order before reporting failure; session health reflects the channel, not an individual URL.
- `channel-browsing`: channel tiles surface current-programme info when available.

## Impact

- `Sources/IPTV/Models/Channel.swift` — `streamURL: URL?` becomes an ordered `streamSources: [URL]` (or equivalent)
- `Sources/IPTV/Models/CatalogJoin.swift` — stop discarding duplicate stream entries; apply official-streams overlay ordering
- `Sources/IPTV/Models/` — new curated official-streams mapping (pattern: like `BroadcastOrder`)
- `Sources/IPTV/ViewModels/PlayerViewModel.swift` — failover to next source on failure before `markFailed`
- `Sources/IPTV/Services/` — new EPG service; possibly a second catalog source behind `ChannelService`
- `Sources/IPTV/Views/ChannelTileView.swift` / `PlayerView.swift` — now-playing programme display
- `StreamProber` / `StreamHealthStore` — health semantics move from "the URL" to "the channel (any source)"
