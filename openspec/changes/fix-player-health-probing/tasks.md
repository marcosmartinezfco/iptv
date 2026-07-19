## 1. Stop the health probe from fighting live playback

- [ ] 1.1 In `ChannelListViewModel.probeCurrentCountry()`, exclude `selectedChannel?.id` from the probe target list
- [ ] 1.2 Verify a channel selected/played while its country's probe pass is still running is not marked failed by that pass
- [ ] 1.3 Verify deselecting/switching away from a channel allows it to be probed normally on the next `probeCurrentCountry()` run

## 2. Record successful playback as working

- [ ] 2.1 In `PlayerViewModel.handleStatusChange`, call `healthStore?.markWorking(currentChannelID)` on `.readyToPlay`
- [ ] 2.2 Verify a channel that plays successfully is not hidden by `showOnlyWorkingChannels` afterward

## 3. Retry with backoff on transient network failures

- [ ] 3.1 Add retry (2 attempts, short fixed backoff) to `StreamProber.isAlive`
- [ ] 3.2 Add retry (2 attempts, short fixed backoff) to `ChannelService`'s catalog fetch (`fetchJSON`)
- [ ] 3.3 Verify a single simulated transient failure (timeout/non-2xx) recovers on retry without marking the channel/fetch as failed

## 4. Fullscreen/expand control on the player

- [ ] 4.1 Ensure the app window's `collectionBehavior` includes `.fullScreenPrimary`
- [ ] 4.2 Add an expand/fullscreen button to `PlayerView` that calls `NSWindow.toggleFullScreen(_:)` on the player's window
- [ ] 4.3 Verify entering and exiting fullscreen via the control works, and playback continues uninterrupted across the transition

## 5. Verification

- [ ] 5.1 `swift build` and `swift test` pass
- [ ] 5.2 `swiftlint --strict` and `swiftformat --lint` pass
- [ ] 5.3 Manual pass: select a channel in a country with unprobed channels, play it immediately, confirm it stays visible and playing through a full probe pass of that country
