import AVKit
import SwiftUI

struct PlayerView: View {
    var viewModel: PlayerViewModel

    var body: some View {
        ZStack {
            if let player = viewModel.player {
                AVPlayerContainerView(player: player)
            }

            switch viewModel.playbackState {
            case .idle:
                EmptyView()
            case .loading:
                ProgressView("Loading stream…")
            case .playing:
                EmptyView()
            case .failed:
                ContentUnavailableView(
                    "Playback failed",
                    systemImage: "exclamationmark.triangle",
                    description: Text("This stream couldn't be played.")
                )
            case .unavailable:
                ContentUnavailableView(
                    "Stream unavailable",
                    systemImage: "tv.slash",
                    description: Text("This channel has no known stream.")
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // AVPlayerView's floating controls own hit-testing across the whole video
        // frame, which swallows clicks meant for any SwiftUI view overlaid on top of
        // it — so the fullscreen toggle lives in the window toolbar instead, a
        // hit-testing region entirely outside the player's bounds.
        .toolbar {
            if viewModel.player != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        toggleFullScreen()
                    } label: {
                        Image(systemName: "arrow.up.left.and.arrow.down.right")
                    }
                    .help("Toggle Fullscreen")
                }
            }
        }
    }

    /// Resolves the key window at click time rather than caching a reference —
    /// caching via NSViewRepresentable races SwiftUI's view-attachment timing and
    /// can leave a stale/nil window, silently making the button a no-op.
    private func toggleFullScreen() {
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow else { return }
        window.collectionBehavior.insert(.fullScreenPrimary)
        window.toggleFullScreen(nil)
    }
}

private struct AVPlayerContainerView: NSViewRepresentable {
    let player: AVPlayer

    func makeNSView(context _: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.player = player
        view.controlsStyle = .floating
        return view
    }

    func updateNSView(_ nsView: AVPlayerView, context _: Context) {
        if nsView.player !== player {
            nsView.player = player
        }
    }
}
