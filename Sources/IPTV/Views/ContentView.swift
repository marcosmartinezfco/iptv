import SwiftUI

struct ContentView: View {
    @State private var healthStore = StreamHealthStore()
    @State private var viewModel = ChannelListViewModel()
    @State private var playerViewModel = PlayerViewModel()

    private let gridColumns = [GridItem(.adaptive(minimum: 110, maximum: 140), spacing: 16)]

    var body: some View {
        NavigationSplitView {
            sidebar
                .navigationSplitViewColumnWidth(min: 420, ideal: 560)
        } detail: {
            detail
        }
        .task {
            viewModel.healthStore = healthStore
            playerViewModel.healthStore = healthStore
            await viewModel.load()
        }
        .onChange(of: viewModel.selectedChannel) { _, newChannel in
            playerViewModel.play(channel: newChannel)
        }
        .preferredColorScheme(.dark)
        .tint(.purple)
    }

    @ViewBuilder
    private var detail: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let channel = viewModel.selectedChannel {
                PlayerView(viewModel: playerViewModel)
                    .navigationTitle(channel.name)
            } else {
                ContentUnavailableView {
                    Label("Select a channel", systemImage: "play.tv")
                }
            }
        }
    }

    @ViewBuilder
    private var sidebar: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            switch viewModel.loadState {
            case .loading:
                skeletonGrid
            case .failed:
                ContentUnavailableView {
                    Label("Couldn't load channels", systemImage: "wifi.exclamationmark")
                } actions: {
                    Button("Retry") {
                        Task { await viewModel.load() }
                    }
                }
            case .loaded:
                channelGrid
            }
        }
        .navigationTitle("Channels")
    }

    private var skeletonGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(0..<12, id: \.self) { _ in
                    SkeletonChannelTileView()
                }
            }
            .padding(16)
        }
    }

    private var channelGrid: some View {
        VStack(spacing: 0) {
            filterBar
            if viewModel.filteredChannels.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(viewModel.groupedChannels, id: \.category) { group in
                            categorySection(group)
                        }
                    }
                    .padding(.vertical, 16)
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search channels")
    }

    private func categorySection(_ group: (category: String, channels: [Channel])) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(group.category)
                .font(.title3.bold())
                .padding(.horizontal, 16)

            LazyVGrid(columns: gridColumns, spacing: 16) {
                ForEach(group.channels) { channel in
                    ChannelTileView(
                        channel: channel,
                        isSelected: viewModel.selectedChannel == channel
                    )
                    .onTapGesture {
                        viewModel.selectedChannel = channel
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    private var filterBar: some View {
        HStack(spacing: 16) {
            Picker("Country", selection: $viewModel.countryFilter) {
                Text("All Countries").tag(String?.none)
                ForEach(viewModel.availableCountries, id: \.self) { country in
                    Text(country).tag(String?.some(country))
                }
            }
            .pickerStyle(.menu)
            .fixedSize()

            Toggle("Show only working channels", isOn: $viewModel.showOnlyWorkingChannels)
                .toggleStyle(.switch)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}
