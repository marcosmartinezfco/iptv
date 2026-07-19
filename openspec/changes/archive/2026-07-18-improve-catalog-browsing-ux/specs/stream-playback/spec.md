## MODIFIED Requirements

### Requirement: Surface playback loading and error states
The system SHALL show a loading state while a stream is buffering and an error state if playback fails, distinct from the "no stream URL" state, and SHALL record a playback failure in the session-scoped stream health state so the channel can be excluded by the "working channels only" browsing filter.

#### Scenario: Stream is buffering
- **WHEN** a selected channel's stream has been requested but has not yet started playing
- **THEN** the system SHALL display a loading indicator in the player area

#### Scenario: Stream fails to play
- **WHEN** a selected channel's stream URL fails to load or play (e.g. dead link, unsupported format, network error)
- **THEN** the system SHALL display a playback error state rather than a blank or frozen player

#### Scenario: Failed stream is recorded for the session
- **WHEN** a selected channel's stream fails to play
- **THEN** the system SHALL mark that channel as failed in the session-scoped stream health state, persisting only for the current app session and cleared on relaunch
