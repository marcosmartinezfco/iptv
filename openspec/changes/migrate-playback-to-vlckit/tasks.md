## 1. Spike: VLCKit integration (gates everything below)

- [ ] 1.1 Find a working SPM integration path for VLCKit on macOS (proper Swift package, or a `.binaryTarget` against VLCKit's distributed `.xcframework`)
- [ ] 1.2 Confirm the result is a **dynamically** linked framework, not statically linked — required for LGPL compliance now that this project distributes compiled binaries via `Scripts/package-app.sh`/the release workflow
- [ ] 1.3 Build a throwaway minimal `VLCMediaPlayer` + `VLCVideoView` proof of concept against one real `iptv-org` stream URL, confirm it plays
- [ ] 1.4 **Decision point**: if 1.1 or 1.2 fail cleanly, STOP — report back to the app owner with what was tried and why, rather than picking a workaround (e.g. static linking, manual framework vendoring) unilaterally

## 2. Playback engine swap

- [ ] 2.1 Add the VLCKit dependency to `Package.swift` per the spike's chosen integration method
- [ ] 2.2 In `PlayerViewModel`, replace `AVPlayer`/`AVPlayerItem` with `VLCMediaPlayer`, mapping its delegate-based state callbacks onto the existing `PlaybackState` enum (`idle`/`loading`/`playing`/`failed`/`unavailable`) — no change to the enum itself or to `StreamHealthStore` integration
- [ ] 2.3 Verify `markWorking`/`markFailed` still fire correctly against the new engine's state callbacks

## 3. Main player view

- [ ] 3.1 Replace `AVPlayerContainerView` in `PlayerView.swift` with a VLCKit video view wrapper (`NSViewRepresentable` around `VLCVideoView`/a plain `NSView` VLCKit renders into)
- [ ] 3.2 Add a minimal custom transport control (mute/volume at minimum — live TV has no timeline to scrub)
- [ ] 3.3 Remove the AVKit-specific lines (`showsFullScreenToggleButton`, `allowsPictureInPicturePlayback`, `allowsMagnification`) — no VLCKit equivalents
- [ ] 3.4 Verify manually: channel plays, loading/failed/unavailable states still render correctly

## 4. Fullscreen presenter

- [ ] 4.1 Re-point `StreamFullScreenPresenter` at the VLCKit view instead of a second `AVPlayerView`
- [ ] 4.2 Verify manually: toolbar expand button still enters/exits the dedicated fullscreen window correctly, Esc still dismisses it, playback continues uninterrupted across the transition

## 5. License compliance

- [ ] 5.1 Add an LGPL notice for VLCKit/libVLC to the README, linking to VLC's source
- [ ] 5.2 Re-confirm (post-integration) that the shipped `.app` from `Scripts/package-app.sh` embeds VLCKit as a dynamic framework, not statically linked

## 6. Verification

- [ ] 6.1 `swift build` and `swiftformat --lint` pass
- [ ] 6.2 Manual pass: play several channels that previously failed in AVPlayer (if any known from prior testing), confirm improvement; play several that already worked, confirm no regression
- [ ] 6.3 `openspec validate migrate-playback-to-vlckit --strict` passes
