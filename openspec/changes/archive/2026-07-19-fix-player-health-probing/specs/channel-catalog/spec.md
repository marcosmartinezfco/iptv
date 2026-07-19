## MODIFIED Requirements

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
