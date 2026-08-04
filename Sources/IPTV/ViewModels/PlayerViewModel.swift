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

    /// Sources tried per channel before giving up — bounds worst-case start
    /// latency (each attempt has its own AVPlayer timeout) while still covering
    /// the common "first mirror is dead" case.
    private static let maxSourceAttempts = 3

    private(set) var playbackState: PlaybackState = .idle
    private(set) var player: AVPlayer?
    /// True while a source has failed and the next one is being tried, so the UI
    /// can say "trying another source…" instead of flashing an error.
    private(set) var isFailingOver = false
    var healthStore: StreamHealthStore?

    private var statusObservation: NSKeyValueObservation?
    private var currentChannelID: Channel.ID?
    private var pendingSources: [URL] = []

    func play(channel: Channel?) {
        currentChannelID = channel?.id
        statusObservation = nil
        player?.pause()
        player = nil
        pendingSources = []
        isFailingOver = false

        guard let channel else {
            playbackState = .idle
            return
        }

        guard !channel.streamSources.isEmpty else {
            playbackState = .unavailable
            return
        }

        pendingSources = Array(channel.streamSources.prefix(Self.maxSourceAttempts))
        playbackState = .loading
        playNextSource()
    }

    private func playNextSource() {
        guard !pendingSources.isEmpty else { return }
        let url = pendingSources.removeFirst()
        NSLog("PlayerViewModel: attempting source %@", url.absoluteString)

        let item = AVPlayerItem(url: url)
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
            isFailingOver = false
            if let currentChannelID {
                healthStore?.markWorking(currentChannelID)
            }
        case .failed:
            if pendingSources.isEmpty {
                let error = player?.currentItem?.error ?? URLError(.unknown)
                playbackState = .failed(error)
                isFailingOver = false
                if let currentChannelID {
                    healthStore?.markFailed(currentChannelID)
                }
            } else {
                NSLog("PlayerViewModel: source failed, failing over (%d left)", pendingSources.count)
                isFailingOver = true
                playbackState = .loading
                statusObservation = nil
                player?.pause()
                playNextSource()
            }
        case .unknown:
            break
        @unknown default:
            break
        }
    }
}
