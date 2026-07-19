import AVKit
import SwiftUI

struct PlayerView: View {
    var viewModel: PlayerViewModel

    var body: some View {
        ZStack(alignment: .topTrailing) {
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

            if viewModel.player != nil {
                Button {
                    toggleFullScreen()
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(8)
                        .background(.black.opacity(0.5), in: Circle())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(12)
                .zIndex(1)
                .help("Toggle Fullscreen")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
