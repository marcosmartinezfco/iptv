## 1. Multi-source model

- [ ] 1.1 Change `Channel.streamURL: URL?` to ordered `streamSources: [URL]`; fix all consumers the compiler flags
- [ ] 1.2 In `CatalogJoin`, keep every `streams.json` URL per channel (source order) instead of discarding duplicates
- [ ] 1.3 Add the curated official-streams mapping (seed: RTVE — La 1, La 2, 24h, Teledeporte, Clan; hand-verify each URL plays) and prepend matches in the join
- [ ] 1.4 Update `StreamProber`/probe scheduling to probe a channel's top-priority source

## 2. Playback failover

- [ ] 2.1 In `PlayerViewModel`, on source failure advance to the next source (attempt cap: 3) and replay; `markFailed` only after exhaustion, `markWorking` on first success
- [ ] 2.2 Keep the loading state up during failover (optionally "trying another source…") instead of flashing an error between attempts
- [ ] 2.3 Verify manually: a channel whose first URL is dead but has a working later URL plays without being hidden

## 3. Spike: additional catalogs (gates task 4)

- [ ] 3.1 Evaluate Free-TV/IPTV (and any comparable open catalog): how many channels are net-new vs iptv-org for the user's countries, and does id/name+country dedupe hold up?
- [ ] 3.2 Decision point: adopt (proceed to 4) or drop (delete task 4 and the corresponding ADDED requirement from the channel-catalog delta at archive time); report findings either way

## 4. Additional catalog merge (only if 3.2 adopts)

- [ ] 4.1 Add the second catalog source behind `ChannelService` and merge/dedupe into the joined catalog per the spike's rules
- [ ] 4.2 Verify manually: no visible duplicate channels in browsing; net-new channels present and playable

## 5. Spike: EPG source (gates task 6)

- [ ] 5.1 Evaluate hosted XMLTV endpoints vs. iptv-org/epg outputs against the design's criteria (no self-hosted scraping, Spanish coverage first, plain-XML parseable); pick one
- [ ] 5.2 Confirm the chosen source's terms permit this use and its per-country feed sizes are manageable

## 6. EPG integration

- [ ] 6.1 Add an EPG service: fetch per browsed country, streaming-parse XMLTV via `XMLParser`, keep only now/next per channel, session cache with coarse refresh
- [ ] 6.2 Show the current programme title in the player area for the selected channel
- [ ] 6.3 Show the current programme title on channel tiles where data exists
- [ ] 6.4 Verify manually: Spanish channels show believable now-playing titles; channels without data render unchanged

## 7. Verification

- [ ] 7.1 `swift build` and `swiftformat --lint` pass
- [ ] 7.2 Manual regression pass: playback, failover, fullscreen, working-only filter, favorites default country
- [ ] 7.3 `openspec validate expand-channel-sources-and-epg --strict` passes
