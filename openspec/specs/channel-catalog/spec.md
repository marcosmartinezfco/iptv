# channel-catalog Specification

## Purpose
Fetch, decode, join, and cache the iptv-org channel catalog (channels, streams, countries, categories) in memory for the app session.
## Requirements
### Requirement: Fetch iptv-org catalog data
The system SHALL fetch channels, streams, countries, and categories from the public `iptv-org/api` JSON endpoints over HTTPS when the catalog is loaded, retrying a transiently failed request with backoff before surfacing a failure.

#### Scenario: Successful fetch on launch
- **WHEN** the app requests the channel catalog
- **THEN** it fetches `channels.json`, `streams.json`, `countries.json`, and `categories.json` from `iptv-org/api` and decodes them into typed models

#### Scenario: Network fetch fails
- **WHEN** any of the four catalog requests fails after retries (network error, non-2xx response, or decode error)
- **THEN** the system SHALL surface a catalog load failure to callers rather than returning a partial or silently empty catalog

#### Scenario: Transient fetch failure recovers on retry
- **WHEN** a catalog request fails with a transient error (e.g. timeout, non-2xx)
- **THEN** the system SHALL retry the request at least once with a short backoff before surfacing a failure, and SHALL succeed without error if a retry succeeds

### Requirement: Join channels with their stream, country, and category data
The system SHALL join fetched channels, streams, countries, and categories into a single `Channel` collection keyed by channel id, associating each channel with an ordered list of stream source URLs (possibly empty), its country, and categories. The order SHALL encode playback priority: curated official broadcaster URLs first, then community catalog URLs in their source order.

#### Scenario: Channel has multiple matching streams
- **WHEN** a channel id in `channels.json` has several corresponding entries in `streams.json`
- **THEN** the resulting `Channel` includes all of those stream URLs, in their source order, rather than only the first

#### Scenario: Channel has an official broadcaster stream
- **WHEN** a channel id appears in the curated official-streams mapping
- **THEN** the official URL SHALL be first in that channel's stream source list, ahead of any community-catalog URLs

#### Scenario: Channel has no matching stream
- **WHEN** a channel id in `channels.json` has no corresponding entry in `streams.json` and no official-streams entry
- **THEN** the resulting `Channel` is still included in the catalog with an empty stream source list, so it remains browsable but not playable

<!-- The originally-drafted "Merge additional open channel catalogs" requirement was
     removed per its own spike gate: the Free-TV/IPTV evaluation found essentially
     zero net-new Spanish channels (unmatched ids were the same channels under
     different spellings) and unreliable dedupe (506 entries with empty ids).
     See tasks.md section 3 for the spike record. -->

### Requirement: Tolerate malformed catalog entries
The system SHALL skip individual malformed entries during decoding rather than failing the entire catalog fetch, when the source data has missing or invalid optional fields.

#### Scenario: One malformed channel entry among many valid ones
- **WHEN** the fetched `channels.json` contains one entry missing a required field alongside many well-formed entries
- **THEN** the system SHALL decode and return the well-formed entries and omit only the malformed one

### Requirement: In-memory catalog caching for the app session
The system SHALL cache the joined catalog in memory after the first successful fetch and SHALL NOT persist it to disk.

#### Scenario: Repeated catalog requests within a session
- **WHEN** the catalog is requested again after a successful fetch earlier in the same app session
- **THEN** the system SHALL return the cached result without issuing new network requests

#### Scenario: App relaunch
- **WHEN** the app is relaunched
- **THEN** the system SHALL fetch the catalog fresh from the network, since no on-disk cache exists

