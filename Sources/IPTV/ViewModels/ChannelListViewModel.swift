import Foundation
import Observation

@Observable
@MainActor
final class ChannelListViewModel {
    enum LoadState {
        case loading
        case loaded
        case failed(Error)
    }

    private(set) var channels: [Channel] = []
    private(set) var loadState: LoadState = .loading
    private(set) var isProbing = false
    var selectedChannel: Channel?

    var searchText: String = ""
    var countryFilter: String? {
        didSet { probeCurrentCountry() }
    }

    var showOnlyWorkingChannels: Bool = true

    private let service: ChannelService
    private let prober = StreamProber()
    private var probeTask: Task<Void, Never>?
    var healthStore: StreamHealthStore?

    init(service: ChannelService = IPTVOrgChannelService()) {
        self.service = service
    }

    var availableCountries: [String] {
        Set(channels.compactMap(\.country)).sorted()
    }

    var filteredChannels: [Channel] {
        channels.filter { channel in
            channel.streamURL != nil
                && (countryFilter == nil || channel.country == countryFilter)
                && (searchText.isEmpty || channel.name.localizedCaseInsensitiveContains(searchText))
                && (!showOnlyWorkingChannels || (healthStore?.isWorking(channel.id) ?? true))
        }
    }

    /// Curated broadcast/dial order first (e.g. La 1, La 2, Antena 3 … for Spain),
    /// then everything else alphabetically.
    var displayChannels: [Channel] {
        filteredChannels.sorted { lhs, rhs in
            let lhsRank = BroadcastOrder.rank(channelID: lhs.id, country: lhs.country) ?? Int.max
            let rhsRank = BroadcastOrder.rank(channelID: rhs.id, country: rhs.country) ?? Int.max
            if lhsRank != rhsRank { return lhsRank < rhsRank }
            return lhs.name.localizedCaseInsensitiveCompare(rhs.name) == .orderedAscending
        }
    }

    func load() async {
        loadState = .loading
        do {
            channels = try await service.fetchChannels()
            loadState = .loaded
            probeCurrentCountry()
        } catch {
            loadState = .failed(error)
        }
    }

    /// Probes the selected country's streams in the background, marking dead ones
    /// in the health store so the working-only filter hides them as results come in.
    /// Skipped for "All Countries" — probing the entire catalog would be excessive.
    func probeCurrentCountry() {
        probeTask?.cancel()
        guard let healthStore, let countryFilter else {
            isProbing = false
            return
        }

        let targets: [(id: Channel.ID, url: URL)] = channels.compactMap { channel in
            guard channel.country == countryFilter,
                  let url = channel.streamURL,
                  !healthStore.isProbed(channel.id)
            else { return nil }
            return (channel.id, url)
        }
        guard !targets.isEmpty else {
            isProbing = false
            return
        }

        isProbing = true
        probeTask = Task { [prober] in
            await withTaskGroup(of: (Channel.ID, Bool).self) { group in
                var next = 0
                let maxConcurrent = 8

                while next < min(maxConcurrent, targets.count) {
                    let target = targets[next]
                    group.addTask { (target.id, await prober.isAlive(target.url)) }
                    next += 1
                }

                for await (channelID, alive) in group {
                    if Task.isCancelled { break }
                    alive ? healthStore.markWorking(channelID) : healthStore.markFailed(channelID)
                    if next < targets.count {
                        let target = targets[next]
                        group.addTask { (target.id, await prober.isAlive(target.url)) }
                        next += 1
                    }
                }
            }
            if !Task.isCancelled {
                isProbing = false
            }
        }
    }
}
