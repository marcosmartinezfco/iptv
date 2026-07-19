import AVKit
import SwiftUI

struct PlayerView: View {
    var viewModel: PlayerViewModel

    @State private var window: NSWindow?

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
                    window?.toggleFullScreen(nil)
                } label: {
                    Image(systemName: "arrow.up.left.and.arrow.down.right")
                        .font(.system(size: 12, weight: .semibold))
                        .padding(8)
                        .background(.black.opacity(0.5), in: Circle())
                        .foregroundStyle(.white)
                }
                .buttonStyle(.plain)
                .padding(12)
                .help("Toggle Fullscreen")
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(WindowAccessor(window: $window))
    }
}

/// Captures the hosting NSWindow and ensures it supports fullscreen, since this
/// SwiftUI app has no AppDelegate/window controller to configure that otherwise.
/// Uses `viewDidMoveToWindow` rather than a one-shot async read in `makeNSView`,
/// since at that point SwiftUI often hasn't attached the view to a window yet —
/// which was silently leaving `window` nil and making the fullscreen button a no-op.
private struct WindowAccessor: NSViewRepresentable {
    @Binding var window: NSWindow?

    func makeNSView(context _: Context) -> NSView {
        let view = WindowObservingView()
        view.onWindowChange = { newWindow in
            guard let newWindow else { return }
            newWindow.collectionBehavior.insert(.fullScreenPrimary)
            DispatchQueue.main.async { window = newWindow }
        }
        return view
    }

    func updateNSView(_: NSView, context _: Context) {}
}

private final class WindowObservingView: NSView {
    var onWindowChange: (NSWindow?) -> Void = { _ in }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        onWindowChange(window)
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
