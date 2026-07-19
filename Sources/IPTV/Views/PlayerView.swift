import AVKit
import SwiftUI

struct PlayerView: View {
    var viewModel: PlayerViewModel

    @State private var fullScreenPresenter = StreamFullScreenPresenter()

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
        // it — so the expand toggle lives in the window toolbar instead, a
        // hit-testing region entirely outside the player's bounds.
        .toolbar {
            if let player = viewModel.player {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        NSLog("PlayerView: fullscreen toolbar button clicked")
                        fullScreenPresenter.toggle(player: player)
                    } label: {
                        Image(systemName: fullScreenPresenter.isPresenting
                            ? "arrow.down.right.and.arrow.up.left"
                            : "arrow.up.left.and.arrow.down.right")
                    }
                    .help(fullScreenPresenter.isPresenting ? "Exit Fullscreen" : "Fullscreen")
                }
            }
        }
        .onChange(of: viewModel.player == nil) { _, playerGone in
            if playerGone {
                fullScreenPresenter.dismiss()
            }
        }
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
