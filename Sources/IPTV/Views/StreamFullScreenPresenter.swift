import AppKit
import AVKit
import Observation

/// Presents the stream in a dedicated borderless window covering the whole screen,
/// bypassing both SwiftUI window management and macOS Spaces fullscreen — the former
/// can silently ignore layout changes, the latter is only granted to
/// LaunchServices-launched bundles. A plain window at screen size with the menu bar
/// and Dock auto-hidden works identically under `swift run` and a bundled launch.
/// AVPlayer supports rendering into multiple layers at once, so the main window's
/// player keeps working behind the fullscreen one.
@Observable
@MainActor
final class StreamFullScreenPresenter {
    private var fullScreenWindow: NSWindow?

    var isPresenting: Bool {
        fullScreenWindow != nil
    }

    func toggle(player: AVPlayer) {
        if isPresenting {
            dismiss()
        } else {
            present(player: player)
        }
    }

    func present(player: AVPlayer) {
        NSLog("StreamFullScreenPresenter.present: entering fullscreen")
        guard fullScreenWindow == nil else { return }
        guard let screen = NSApp.keyWindow?.screen ?? NSScreen.main else {
            NSLog("StreamFullScreenPresenter.present: no screen available, aborting")
            return
        }

        let playerView = AVPlayerView()
        playerView.player = player
        playerView.controlsStyle = .floating

        let window = EscapableWindow(
            contentRect: screen.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.onEscape = { [weak self] in self?.dismiss() }
        window.level = .mainMenu + 1
        window.backgroundColor = .black
        window.isReleasedWhenClosed = false
        window.contentView = playerView

        NSApp.presentationOptions = [.autoHideMenuBar, .autoHideDock]
        window.makeKeyAndOrderFront(nil)
        fullScreenWindow = window
        NSLog("StreamFullScreenPresenter.present: fullscreen window shown at %@", NSStringFromRect(screen.frame))
    }

    func dismiss() {
        NSLog("StreamFullScreenPresenter.dismiss: leaving fullscreen")
        NSApp.presentationOptions = []
        fullScreenWindow?.contentView = nil
        fullScreenWindow?.orderOut(nil)
        fullScreenWindow = nil
        NSApp.mainWindow?.makeKeyAndOrderFront(nil)
    }
}

/// Borderless windows refuse key status by default, which would break both the
/// player's floating controls and Esc handling — so both are overridden here.
private final class EscapableWindow: NSWindow {
    var onEscape: (() -> Void)?

    override var canBecomeKey: Bool {
        true
    }

    override var canBecomeMain: Bool {
        true
    }

    override func cancelOperation(_: Any?) {
        onEscape?()
    }
}
