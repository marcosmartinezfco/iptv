## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: Merge additional open channel catalogs when adopted
If the additional-catalog evaluation (see the change's design) is adopted, the system SHALL merge channels from the additional open catalog into the iptv-org catalog, deduplicating so a broadcast channel appears once, with stream URLs from all catalogs contributing to its ordered source list. If the evaluation is not adopted, this requirement is void and SHALL be removed at archive time.

#### Scenario: Channel exists in both catalogs
- **WHEN** the same broadcast channel appears in iptv-org and in the additional catalog
- **THEN** the catalog SHALL contain one entry for it whose source list includes the distinct stream URLs from both

#### Scenario: Channel exists only in the additional catalog
- **WHEN** a channel appears only in the additional catalog
- **THEN** it SHALL appear in the app's catalog alongside iptv-org channels, indistinguishable in browsing behavior
