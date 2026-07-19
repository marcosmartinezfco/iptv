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

    /// Expanding the player means the *video* gets big, not the app window — so this
    /// collapses the sidebar/channel-grid columns to show only the player, and also
    /// requests real OS fullscreen as a bonus when the window supports it (silently
    /// does nothing under `swift run`'s bundle-less process, which is fine — the
    /// column collapse alone still gives a much larger video area).
    private func toggleExpanded() {
        columnVisibility = isExpanded ? .all : .detailOnly
        if let window = NSApp.keyWindow ?? NSApp.mainWindow {
            window.collectionBehavior.insert(.fullScreenPrimary)
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
