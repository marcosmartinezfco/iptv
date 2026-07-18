import AVFoundation
import Foundation
import Observation

@Observable
@MainActor
final class PlayerViewModel {
    enum PlaybackState {
        case idle
        case loading
        case playing
        case failed(Error)
        case unavailable
    }

    private(set) var playbackState: PlaybackState = .idle
    private(set) var player: AVPlayer?

    private var statusObservation: NSKeyValueObservation?

    func play(channel: Channel?) {
        statusObservation = nil
        player?.pause()
        player = nil

        guard let channel else {
            playbackState = .idle
            return
        }

        guard let streamURL = channel.streamURL else {
            playbackState = .unavailable
            return
        }

        playbackState = .loading
        let item = AVPlayerItem(url: streamURL)
        let newPlayer = AVPlayer(playerItem: item)
        player = newPlayer

        statusObservation = item.observe(\.status, options: [.new]) { [weak self] item, _ in
            Task { @MainActor in
                self?.handleStatusChange(item.status)
            }
        }

        newPlayer.play()
    }

    private func handleStatusChange(_ status: AVPlayerItem.Status) {
        switch status {
        case .readyToPlay:
            playbackState = .playing
        case .failed:
            playbackState = .failed(player?.currentItem?.error ?? URLError(.unknown))
        case .unknown:
            break
        @unknown default:
            break
        }
    }
}
