# channel-catalog Specification

## Purpose
TBD - created by archiving change add-catalog-browsing-and-playback. Update Purpose after archive.

## Requirements

### Requirement: Fetch iptv-org catalog data
The system SHALL fetch channels, streams, countries, and categories from the public `iptv-org/api` JSON endpoints over HTTPS when the catalog is loaded.

#### Scenario: Successful fetch on launch
- **WHEN** the app requests the channel catalog
- **THEN** it fetches `channels.json`, `streams.json`, `countries.json`, and `categories.json` from `iptv-org/api` and decodes them into typed models

#### Scenario: Network fetch fails
- **WHEN** any of the four catalog requests fails (network error, non-2xx response, or decode error)
- **THEN** the system SHALL surface a catalog load failure to callers rather than returning a partial or silently empty catalog

### Requirement: Join channels with their stream, country, and category data
The system SHALL join fetched channels, streams, countries, and categories into a single `Channel` collection keyed by channel id, associating each channel with its stream URL (if any), country, and categories.

#### Scenario: Channel has a matching stream
- **WHEN** a channel id in `channels.json` has a corresponding entry in `streams.json`
- **THEN** the resulting `Channel` includes that stream's URL

#### Scenario: Channel has no matching stream
- **WHEN** a channel id in `channels.json` has no corresponding entry in `streams.json`
- **THEN** the resulting `Channel` is still included in the catalog, with a `nil`/absent stream URL, so it remains browsable but not playable

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
