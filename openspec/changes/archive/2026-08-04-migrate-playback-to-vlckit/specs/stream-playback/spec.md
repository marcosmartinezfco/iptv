## MODIFIED Requirements

### Requirement: Play the selected channel's stream
The system SHALL play the selected channel's stream using VLCKit when a channel with a stream URL is selected.

#### Scenario: Selecting a channel with a valid stream
- **WHEN** the user selects a channel that has a stream URL
- **THEN** the system SHALL load and begin playback of that stream in the player view

#### Scenario: Switching between channels
- **WHEN** the user selects a different channel while one is already playing
- **THEN** the system SHALL stop the current playback and begin loading the newly selected channel's stream

## REMOVED Requirements

### Requirement: Support Picture-in-Picture and zoom
**Reason**: Picture-in-Picture and AVKit's native fullscreen toggle are AVKit-specific conveniences with no VLCKit equivalent. Reimplementing Picture-in-Picture (a persistent, always-on-top floating window with its own lifecycle) from scratch is out of scope for this playback-engine migration.
**Migration**: No replacement in this change. The app's own custom fullscreen (toolbar expand button + dedicated fullscreen window, `StreamFullScreenPresenter`) is unaffected and remains the primary way to view a stream larger — see the still-active "Expand the player to fullscreen" requirement. Picture-in-Picture may be revisited as a separate future proposal if wanted.
