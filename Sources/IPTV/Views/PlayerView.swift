import AVKit
import SwiftUI

struct PlayerView: View {
    var viewModel: PlayerViewModel
    @Binding var columnVisibility: NavigationSplitViewVisibility

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
            if viewModel.player != nil {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        toggleExpanded()
                    } label: {
                        Image(systemName: isExpanded
                            ? "arrow.down.right.and.arrow.up.left"
                            : "arrow.up.left.and.arrow.down.right")
                    }
                    .help(isExpanded ? "Show Sidebar" : "Expand Player")
                }
            }
        }
    }

    private var isExpanded: Bool {
        columnVisibility == .detailOnly
    }

    /// Stream fullscreen: the *video* fills the screen — collapse the sidebar/grid
    /// columns and enter OS fullscreen together. Distinct from plain window
    /// fullscreen (green traffic light), which keeps all three columns visible.
    /// Checks the window's actual fullscreen state rather than blindly toggling,
    /// so exiting via Esc doesn't leave the button out of sync and re-entering
    /// fullscreen when it meant to leave.
    private func toggleExpanded() {
        let expanding = !isExpanded
        columnVisibility = expanding ? .detailOnly : .all
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow else { return }
        window.collectionBehavior.insert(.fullScreenPrimary)
        if window.styleMask.contains(.fullScreen) != expanding {
            window.toggleFullScreen(nil)
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
