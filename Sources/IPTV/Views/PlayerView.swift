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
