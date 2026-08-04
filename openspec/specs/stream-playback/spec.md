# stream-playback Specification

## Purpose
Play a selected channel's stream via AVKit, surfacing loading, failure, and unavailable states.
## Requirements
### Requirement: Play the selected channel's stream
The system SHALL play the selected channel using AVKit/AVPlayer, attempting the channel's stream sources in priority order: when a source fails to load or play, the system SHALL automatically try the next source (up to a small attempt cap) before reporting playback failure.

#### Scenario: First source plays
- **WHEN** the user selects a channel and its first stream source loads successfully
- **THEN** the system SHALL play it without touching the remaining sources

#### Scenario: First source fails, a later one works
- **WHEN** the user selects a channel whose first stream source fails to load or play, and a subsequent source works
- **THEN** the system SHALL fail over automatically and play the working source, without the user re-selecting the channel and without the channel being marked failed

#### Scenario: Switching between channels
- **WHEN** the user selects a different channel while one is already playing
- **THEN** the system SHALL stop the current playback (including any in-progress failover) and begin the newly selected channel's source sequence

### Requirement: Handle channels without a playable stream
The system SHALL indicate that playback is unavailable when the selected channel has no stream sources, without attempting to load a player.

#### Scenario: Selecting a channel with no sources
- **WHEN** the user selects a channel whose stream source list is empty
- **THEN** the system SHALL display a "stream unavailable" state instead of attempting playback

### Requirement: Surface playback loading and error states
The system SHALL show a loading state while a stream is buffering (indicating when a fallback source is being tried), and an error state only after the channel's attempted sources are exhausted, distinct from the "no sources" state. The system SHALL record a channel as failed in the session-scoped stream health state only when all attempted sources failed, and SHALL record the channel as working when any source starts playing.

#### Scenario: Stream is buffering
- **WHEN** a selected channel's current source has been requested but has not yet started playing
- **THEN** the system SHALL display a loading indicator in the player area

#### Scenario: Failover in progress
- **WHEN** a source has failed and the system is attempting the next source
- **THEN** the loading state SHALL remain (optionally indicating another source is being tried) rather than flashing an error

#### Scenario: All sources fail
- **WHEN** every attempted source for the selected channel fails to load or play
- **THEN** the system SHALL display a playback error state and mark the channel as failed in the session-scoped stream health state, persisting only for the current app session

#### Scenario: A source succeeds
- **WHEN** any of the channel's sources successfully becomes ready to play
- **THEN** the system SHALL mark the channel as working in the session-scoped stream health state, so it is not hidden by the "working channels only" filter for the remainder of the session unless a later playback of it fails

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

