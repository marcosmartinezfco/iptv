## ADDED Requirements

### Requirement: Fetch programme guide data
The system SHALL fetch EPG (programme guide) data from the source selected by the EPG spike, scoped to the channels the user is browsing (e.g. per country), and SHALL cache it in memory for the session with coarse refresh (on country switch or a periodic interval), without persisting it to disk.

#### Scenario: Guide data available for the browsed country
- **WHEN** the user browses a country for which the EPG source has data
- **THEN** the system SHALL fetch and hold current-programme information for that country's channels

#### Scenario: EPG fetch fails
- **WHEN** the EPG fetch fails or the source has no data for a channel
- **THEN** the system SHALL degrade gracefully — channels display without programme info, and browsing/playback are unaffected

### Requirement: Show the currently-airing programme
The system SHALL display the currently-airing programme's title for a channel wherever guide data for it exists, at minimum alongside the selected channel in the player area.

#### Scenario: Channel has guide data
- **WHEN** a channel with current-programme data is selected
- **THEN** the player area SHALL show the programme title currently airing on that channel

#### Scenario: Channel has no guide data
- **WHEN** a channel without guide data is selected
- **THEN** the player area SHALL display exactly as it does today, with no placeholder noise
