## 1. Multi-source model

- [x] 1.1 Change `Channel.streamURL: URL?` to ordered `streamSources: [URL]`; fix all consumers the compiler flags (also added `countryCode` for country-scoped feeds)
- [x] 1.2 In `CatalogJoin`, keep every `streams.json` URL per channel (source order) instead of discarding duplicates — iptv-org data shows 2,509 channels carry more than one URL
- [x] 1.3 Add the curated official-streams mapping (`OfficialStreams.swift`) and prepend matches in the join. Seeded with the four RTVE channels whose first-party `rtvelivestream.rtve.es` endpoints were hand-verified to serve valid HLS manifests (2026-08-04): La 1, La 2, Teledeporte, Clan. 24h was left out — its only official-looking URL (`ztnr.rtve.es`) returned 403 in verification, so it stays on community URLs
- [x] 1.4 Probe scheduling uses a channel's top-priority source (`streamSources.first`)

## 2. Playback failover

- [x] 2.1 `PlayerViewModel` advances to the next source on failure (attempt cap: 3); `markFailed` only after exhaustion, `markWorking` on first success
- [x] 2.2 Loading state stays up during failover, showing "Trying another source…" via `isFailingOver`
- [x] 2.3 Verified manually by the app owner alongside the full pass

## 3. Spike: additional catalogs (gated task 4)

- [x] 3.1 Free-TV/IPTV evaluated against live data: 1,930 channels total, 72 Spain entries; 88% of Spain entries match iptv-org ids exactly, and fuzzy-checking the 9 unmatched showed at least 7 are the same channels under different id spellings (24h.es vs 24Horas.es etc.) — essentially zero net-new Spanish channels. Globally, 506 entries have empty tvg-ids and cannot be deduped at all. Free-TV's value is redundant fallback URLs for channels iptv-org already lists
- [x] 3.2 Decision: **DROP.** Fails both bars (no meaningful net-new channels; dedupe unreliable). The corresponding ADDED requirement was removed from the channel-catalog delta per its own gate. Revisit only as an extra-URLs-onto-existing-ids ingest if multi-source coverage ever feels thin

## 4. Additional catalog merge — DROPPED per 3.2

## 5. Spike: EPG source (gated task 6)

- [x] 5.1 Chose epgshare01.online's per-country XMLTV dumps (`epg_ripper_<CC>1.xml.gz`): hosted (no self-run scrapers, which disqualified iptv-org/epg — its hosted outputs no longer exist), daily-updated, plain XMLTV. Spain feed verified live: 3.1 MB gz → 24 MB XML, 373 channels, all majors present. Fallback candidate: open-epg.com (rate-limited, id format undocumented)
- [x] 5.2 Terms: free for legal use; no documented rate limits; per-country file sizes manageable. Channel-id mismatch with iptv-org (`La.1.es` vs `La1.es`) verified bridgeable by punctuation-stripping normalization (103 ES channels match) plus a 2-entry alias table (`24Horas.es`→`Canal.24.horas.es`, `Clan.es`→`Clan.TVE.es`)

## 6. EPG integration

- [x] 6.1 `EPGService` (fetch + gzip decompress via a small RFC-1952 header parser over Apple's Compression framework + streaming `XMLParser`, keeping only not-yet-ended programmes) and session-scoped `EPGStore` (lazy per-country fetch, 1-hour refresh, silent degradation, remembers countries with no feed)
- [x] 6.2 Current programme title shown as the player's `navigationSubtitle`
- [x] 6.3 Current programme title shown on channel tiles where data exists
- [x] 6.4 Verified manually by the app owner: Spanish channels show now-playing titles on tiles and in the title bar. (Pipeline also verified live in logs: `EPGStore: guide loaded for ES (327 channels)`)

## 7. Verification

- [x] 7.1 `swift build` and `swiftformat --lint` pass
- [x] 7.2 Manual regression pass by the app owner: playback (La 1/La 2 via official RTVE URLs), fullscreen, working-only filter, favorites default country — all confirmed working
- [x] 7.3 `openspec validate expand-channel-sources-and-epg --strict` passes
