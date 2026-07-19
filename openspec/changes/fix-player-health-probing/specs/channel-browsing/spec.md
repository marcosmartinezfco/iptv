## MODIFIED Requirements

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
