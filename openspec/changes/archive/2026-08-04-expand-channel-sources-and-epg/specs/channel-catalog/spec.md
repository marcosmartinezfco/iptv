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

<!-- The originally-drafted "Merge additional open channel catalogs" requirement was
     removed per its own spike gate: the Free-TV/IPTV evaluation found essentially
     zero net-new Spanish channels (unmatched ids were the same channels under
     different spellings) and unreliable dedupe (506 entries with empty ids).
     See tasks.md section 3 for the spike record. -->
