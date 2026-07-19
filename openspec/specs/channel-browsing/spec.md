# channel-browsing Specification

## Purpose
Let the user browse channels country-first, search, and select channels from the fetched catalog.
## Requirements
### Requirement: Display the channel catalog as a browsable tile grid
The system SHALL display fetched channels as a poster-style tile grid, each tile showing the channel's name and logo, and SHALL show skeleton/shimmer placeholder tiles while the catalog is being fetched and an error state with retry if the fetch fails.

#### Scenario: Catalog loads successfully
- **WHEN** the channel content view appears and the catalog fetch succeeds
- **THEN** the system displays channels as a tile grid, each tile showing the channel's name and logo

#### Scenario: Catalog is loading
- **WHEN** the channel content view appears and the catalog fetch has not yet completed
- **THEN** the system displays skeleton/shimmer placeholder tiles instead of an empty grid or a blocking full-screen spinner

#### Scenario: Catalog fetch fails
- **WHEN** the catalog fetch fails
- **THEN** the system displays an error message and a retry action that re-triggers the fetch

### Requirement: Search channels by name
The system SHALL allow the user to search channels by name via a text query, matching case-insensitively against the channel name.

#### Scenario: Search matches channels
- **WHEN** the user enters a search query that matches one or more channel names
- **THEN** the displayed list SHALL only include channels whose name contains the query, case-insensitively

#### Scenario: Search matches nothing
- **WHEN** the user enters a search query that matches no channel names
- **THEN** the displayed list SHALL be empty and the system SHALL indicate no results were found

### Requirement: Select a channel
The system SHALL allow the user to select a channel from the list, making it the current selection for playback.

#### Scenario: User selects a channel
- **WHEN** the user clicks/taps a channel in the list
- **THEN** that channel becomes the selected channel and its detail/playback area updates accordingly

### Requirement: Browse channels country-first, alphabetically
The system SHALL present a country sidebar as the primary navigation entry point — an "All Countries" option plus every country with at least one channel — and SHALL display the selected country's channels as an alphabetically-sorted tile grid. On launch, if one or more default (favorite) countries exist, the system SHALL select the first one (alphabetically) instead of "All Countries".

#### Scenario: Select a country
- **WHEN** the user selects a country in the sidebar
- **THEN** the content grid SHALL show only that country's channels, sorted alphabetically by name

#### Scenario: Select "All Countries"
- **WHEN** the user selects "All Countries"
- **THEN** the content grid SHALL show every channel (subject to any other active filters), sorted alphabetically by name

#### Scenario: Launch with favorite countries
- **WHEN** the app launches and one or more countries are marked as default/favorite
- **THEN** the system SHALL select the first favorite country (alphabetically) instead of showing "All Countries"

#### Scenario: Launch with no favorite countries
- **WHEN** the app launches and no countries are marked as default/favorite
- **THEN** the system SHALL show "All Countries", as before

### Requirement: Pin default countries
The system SHALL let the user star/unstar a country in the sidebar to add or remove it from a persisted set of default countries, and SHALL list default countries in their own pinned section above the full alphabetical country list.

#### Scenario: Star a country
- **WHEN** the user stars a country that is not yet a default
- **THEN** the system SHALL add it to the persisted default countries and show it under "Default Countries"

#### Scenario: Unstar a country
- **WHEN** the user unstars a country that is currently a default
- **THEN** the system SHALL remove it from the persisted default countries and it SHALL no longer appear under "Default Countries"

#### Scenario: Defaults persist across launches
- **WHEN** the app relaunches
- **THEN** the previously starred default countries SHALL still appear under "Default Countries"

### Requirement: Display channel logos in the channel grid
The system SHALL display each channel's logo image in its tile when a logo URL is available, and SHALL show a generic fallback icon when the logo is missing or fails to load.

#### Scenario: Channel has a logo
- **WHEN** a channel tile is displayed and the channel has a logo URL
- **THEN** the system SHALL load and display that logo image in the tile

#### Scenario: Channel has no logo or the logo fails to load
- **WHEN** a channel tile is displayed and the channel has no logo URL, or the logo image fails to load
- **THEN** the system SHALL display a generic fallback channel icon instead of a broken image or blank space

### Requirement: Filter to only show channels with a working stream this session
The system SHALL allow the user to toggle between showing all channels and showing only channels whose stream has not failed to play during the current app session. The background stream-health probe that feeds this filter SHALL NOT probe, and SHALL NOT act on a result for, the channel that is currently selected/playing, and SHALL retry a failed probe request with backoff before marking a channel as failed.

#### Scenario: Toggle to working-only
- **WHEN** the user enables "Show only working channels" and one or more channels' streams have failed to play earlier in the session
- **THEN** the displayed list SHALL exclude those channels

#### Scenario: Toggle back to all channels
- **WHEN** the user disables "Show only working channels"
- **THEN** the displayed list SHALL include all channels again, subject to any other active filters

#### Scenario: No failures yet this session
- **WHEN** the user enables "Show only working channels" and no stream has failed yet this session
- **THEN** the displayed list SHALL be unchanged, since no channel is yet known-failed

#### Scenario: Background probe does not target the selected channel
- **WHEN** the background stream-health probe runs for the current country while a channel in that country is selected/playing
- **THEN** the probe SHALL skip that channel, so it cannot be marked failed by the probe while selected

#### Scenario: Probe retries before marking a channel failed
- **WHEN** a background probe request for a channel's stream fails or times out
- **THEN** the system SHALL retry the probe request at least once with a short backoff before marking the channel as failed

