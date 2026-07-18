import Foundation
import Observation

@Observable
@MainActor
final class ChannelListViewModel {
    var channels: [Channel] = []
    var selectedChannel: Channel?

    private let service: ChannelService

    init(service: ChannelService = PlaceholderChannelService()) {
        self.service = service
    }

    func load() async {
        channels = (try? await service.fetchChannels()) ?? []
    }
}
