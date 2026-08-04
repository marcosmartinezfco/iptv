## ADDED Requirements

### Requirement: Surface current-programme info on channel tiles
The system SHALL show the currently-airing programme title on a channel's tile in the browsing grid when guide data for that channel is available, and SHALL omit it cleanly when not.

#### Scenario: Tile with guide data
- **WHEN** the channel grid displays a channel for which current-programme data exists
- **THEN** the tile SHALL include the currently-airing programme title alongside the channel name

#### Scenario: Tile without guide data
- **WHEN** the channel grid displays a channel with no guide data
- **THEN** the tile SHALL render exactly as it does today, with no empty placeholder
