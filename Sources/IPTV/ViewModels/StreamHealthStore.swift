import Foundation
import Observation

/// Session-scoped stream health, fed by both playback failures and background probes.
/// Channels start out unknown (treated as working) until a probe or playback says otherwise.
@Observable
@MainActor
final class StreamHealthStore {
    private(set) var failedChannelIDs: Set<Channel.ID> = []
    private(set) var probedChannelIDs: Set<Channel.ID> = []

    func markFailed(_ channelID: Channel.ID) {
        failedChannelIDs.insert(channelID)
        probedChannelIDs.insert(channelID)
    }

    func markWorking(_ channelID: Channel.ID) {
        failedChannelIDs.remove(channelID)
        probedChannelIDs.insert(channelID)
    }

    func isWorking(_ channelID: Channel.ID) -> Bool {
        !failedChannelIDs.contains(channelID)
    }

    func isProbed(_ channelID: Channel.ID) -> Bool {
        probedChannelIDs.contains(channelID)
    }
}
