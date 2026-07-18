## MODIFIED Requirements

### Requirement: Display the channel catalog as a browsable list
The system SHALL display fetched channels grouped into sections by category, each row showing the channel's name and logo, and SHALL show skeleton/shimmer placeholder rows while the catalog is being fetched and an error state with retry if the fetch fails.

#### Scenario: Catalog loads successfully
- **WHEN** the channel list view appears and the catalog fetch succeeds
- **THEN** the system displays channels grouped into sections by category, each row showing the channel's name and logo

#### Scenario: Catalog is loading
- **WHEN** the channel list view appears and the catalog fetch has not yet completed
- **THEN** the system displays skeleton/shimmer placeholder rows instead of an empty list or a blocking full-screen spinner

#### Scenario: Catalog fetch fails
- **WHEN** the catalog fetch fails
- **THEN** the system displays an error message and a retry action that re-triggers the fetch

### Requirement: Filter channels by country and category
The system SHALL group the displayed channels into sections by category, and SHALL allow the user to further filter the displayed channels by country, using the country/category data joined onto each channel.

#### Scenario: Browse by category section
- **WHEN** the catalog is loaded
- **THEN** the system SHALL display channels grouped into sections, one per category, with a channel appearing in every category section it belongs to

#### Scenario: Filter by country
- **WHEN** the user selects a country filter
- **THEN** every category section SHALL only include channels associated with that country

#### Scenario: Clear country filter
- **WHEN** the user clears an active country filter
- **THEN** every category section SHALL return to showing all channels associated with that category (subject to any other active filters)

## ADDED Requirements

### Requirement: Display channel logos in the channel list
The system SHALL display each channel's logo image in its list row when a logo URL is available, and SHALL show a generic fallback icon when the logo is missing or fails to load.

#### Scenario: Channel has a logo
- **WHEN** a channel row is displayed and the channel has a logo URL
- **THEN** the system SHALL load and display that logo image in the row

#### Scenario: Channel has no logo or the logo fails to load
- **WHEN** a channel row is displayed and the channel has no logo URL, or the logo image fails to load
- **THEN** the system SHALL display a generic fallback channel icon instead of a broken image or blank space

### Requirement: Filter to only show channels with a working stream this session
The system SHALL allow the user to toggle between showing all channels and showing only channels whose stream has not failed to play during the current app session.

#### Scenario: Toggle to working-only
- **WHEN** the user enables "Show only working channels" and one or more channels' streams have failed to play earlier in the session
- **THEN** the displayed list SHALL exclude those channels

#### Scenario: Toggle back to all channels
- **WHEN** the user disables "Show only working channels"
- **THEN** the displayed list SHALL include all channels again, subject to any other active filters

#### Scenario: No failures yet this session
- **WHEN** the user enables "Show only working channels" and no stream has failed yet this session
- **THEN** the displayed list SHALL be unchanged, since no channel is yet known-failed
