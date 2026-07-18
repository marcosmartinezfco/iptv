# channel-browsing Specification

## Purpose
TBD - created by archiving change add-catalog-browsing-and-playback. Update Purpose after archive.

## Requirements

### Requirement: Display the channel catalog as a browsable list
The system SHALL display fetched channels in a list, and SHALL show a loading indicator while the catalog is being fetched and an error state with retry if the fetch fails.

#### Scenario: Catalog loads successfully
- **WHEN** the channel list view appears and the catalog fetch succeeds
- **THEN** the system displays the list of channels by name

#### Scenario: Catalog is loading
- **WHEN** the channel list view appears and the catalog fetch has not yet completed
- **THEN** the system displays a loading indicator instead of an empty list

#### Scenario: Catalog fetch fails
- **WHEN** the catalog fetch fails
- **THEN** the system displays an error message and a retry action that re-triggers the fetch

### Requirement: Filter channels by country and category
The system SHALL allow the user to filter the displayed channel list by country and by category, using the country/category data joined onto each channel.

#### Scenario: Filter by country
- **WHEN** the user selects a country filter
- **THEN** the displayed list SHALL only include channels associated with that country

#### Scenario: Filter by category
- **WHEN** the user selects a category filter
- **THEN** the displayed list SHALL only include channels associated with that category

#### Scenario: Clear filters
- **WHEN** the user clears an active country or category filter
- **THEN** the displayed list SHALL return to showing all channels (subject to any other active filters)

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
