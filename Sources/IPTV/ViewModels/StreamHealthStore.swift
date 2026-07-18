import Foundation
import Observation

@Observable
@MainActor
final class StreamHealthStore {
    private(set) var failedChannelIDs: Set<Channel.ID> = []

    func markFailed(_ channelID: Channel.ID) {
        failedChannelIDs.insert(channelID)
    }

    func isWorking(_ channelID: Channel.ID) -> Bool {
        !failedChannelIDs.contains(channelID)
    }
}
