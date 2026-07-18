# stream-playback Specification

## Purpose
Play a selected channel's stream via AVKit, surfacing loading, failure, and unavailable states.

## Requirements

### Requirement: Play the selected channel's stream
The system SHALL play the selected channel's HLS stream using AVKit/AVPlayer when a channel with a stream URL is selected.

#### Scenario: Selecting a channel with a valid HLS stream
- **WHEN** the user selects a channel that has a stream URL
- **THEN** the system SHALL load and begin playback of that stream in the player view

#### Scenario: Switching between channels
- **WHEN** the user selects a different channel while one is already playing
- **THEN** the system SHALL stop the current playback and begin loading the newly selected channel's stream

### Requirement: Handle channels without a playable stream
The system SHALL indicate that playback is unavailable when the selected channel has no stream URL, without attempting to load a player.

#### Scenario: Selecting a channel with no stream
- **WHEN** the user selects a channel that has no associated stream URL
- **THEN** the system SHALL display a "stream unavailable" state instead of attempting playback

### Requirement: Surface playback loading and error states
The system SHALL show a loading state while a stream is buffering and an error state if playback fails, distinct from the "no stream URL" state.

#### Scenario: Stream is buffering
- **WHEN** a selected channel's stream has been requested but has not yet started playing
- **THEN** the system SHALL display a loading indicator in the player area

#### Scenario: Stream fails to play
- **WHEN** a selected channel's stream URL fails to load or play (e.g. dead link, unsupported format, network error)
- **THEN** the system SHALL display a playback error state rather than a blank or frozen player
