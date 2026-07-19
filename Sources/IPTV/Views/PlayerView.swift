import AVKit
import SwiftUI

struct PlayerView: View {
    var viewModel: PlayerViewModel
    @Binding var columnVisibility: NavigationSplitViewVisibility

    @State private var savedWindowFrame: NSRect?

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
    /// columns, resize the window to the screen bounds, and auto-hide the menu bar
    /// and Dock. Done manually rather than via `NSWindow.toggleFullScreen` because
    /// macOS only grants Spaces fullscreen to LaunchServices-launched bundles
    /// (`Scripts/run-app.sh`), silently no-oping under `swift run` — this path
    /// works identically in both launch modes.
    private func toggleExpanded() {
        let expanding = !isExpanded
        columnVisibility = expanding ? .detailOnly : .all
        guard let window = NSApp.keyWindow ?? NSApp.mainWindow else { return }
        if expanding {
            savedWindowFrame = window.frame
            NSApp.presentationOptions = [.autoHideMenuBar, .autoHideDock]
            if let screen = window.screen ?? NSScreen.main {
                window.setFrame(screen.frame, display: true, animate: true)
            }
        } else {
            NSApp.presentationOptions = []
            if let savedWindowFrame {
                window.setFrame(savedWindowFrame, display: true, animate: true)
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
