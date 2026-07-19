## MODIFIED Requirements

### Requirement: Surface playback loading and error states
The system SHALL show a loading state while a stream is buffering and an error state if playback fails, distinct from the "no stream URL" state, SHALL record a playback failure in the session-scoped stream health state so the channel can be excluded by the "working channels only" browsing filter, and SHALL record a successful playback start in the session-scoped stream health state as working.

#### Scenario: Stream is buffering
- **WHEN** a selected channel's stream has been requested but has not yet started playing
- **THEN** the system SHALL display a loading indicator in the player area

#### Scenario: Stream fails to play
- **WHEN** a selected channel's stream URL fails to load or play (e.g. dead link, unsupported format, network error)
- **THEN** the system SHALL display a playback error state rather than a blank or frozen player

#### Scenario: Failed stream is recorded for the session
- **WHEN** a selected channel's stream fails to play
- **THEN** the system SHALL mark that channel as failed in the session-scoped stream health state, persisting only for the current app session and cleared on relaunch

#### Scenario: Successful stream is recorded for the session
- **WHEN** a selected channel's stream successfully becomes ready to play
- **THEN** the system SHALL mark that channel as working in the session-scoped stream health state, so it is not hidden by the "working channels only" filter for the remainder of the session unless a later playback of it fails

## ADDED Requirements

### Requirement: Expand the player to fullscreen
The system SHALL provide a control in the player area that toggles the application window between its normal layout and fullscreen, so the video can be viewed larger than the fixed detail-pane size.

#### Scenario: User expands the player
- **WHEN** the user activates the fullscreen/expand control while a stream is loaded
- **THEN** the system SHALL enter fullscreen, filling the screen with the video

#### Scenario: User exits fullscreen
- **WHEN** the user exits fullscreen (via the same control or the system's standard fullscreen exit)
- **THEN** the system SHALL return to the normal windowed layout with the sidebar and channel grid visible

### Requirement: Support Picture-in-Picture and zoom
The system SHALL allow the user to pop the current stream into a floating Picture-in-Picture window, and SHALL allow the user to magnify (zoom into) the video via a trackpad pinch gesture.

#### Scenario: User starts Picture-in-Picture
- **WHEN** the user activates Picture-in-Picture on a playing stream
- **THEN** the system SHALL continue playback in a floating window that stays visible while the user interacts with other applications

#### Scenario: User pinches to zoom
- **WHEN** the user performs a pinch gesture on the video area
- **THEN** the system SHALL magnify the video in response
