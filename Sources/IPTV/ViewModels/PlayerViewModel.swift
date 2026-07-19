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
    var healthStore: StreamHealthStore?

    private var statusObservation: NSKeyValueObservation?
    private var currentChannelID: Channel.ID?

    func play(channel: Channel?) {
        currentChannelID = channel?.id
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
            if let currentChannelID {
                healthStore?.markWorking(currentChannelID)
            }
        case .failed:
            let error = player?.currentItem?.error ?? URLError(.unknown)
            playbackState = .failed(error)
            if let currentChannelID {
                healthStore?.markFailed(currentChannelID)
            }
        case .unknown:
            break
        @unknown default:
            break
        }
    }
}
