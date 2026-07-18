import SwiftUI

struct ContentView: View {
    @State private var healthStore = StreamHealthStore()
    @State private var countryPreferences = CountryPreferencesStore()
    @State private var viewModel = ChannelListViewModel()
    @State private var playerViewModel = PlayerViewModel()

    private let gridColumns = [GridItem(.adaptive(minimum: 110, maximum: 140), spacing: 16)]

    var body: some View {
        NavigationSplitView {
            countrySidebar
                .navigationSplitViewColumnWidth(min: 220, ideal: 260)
        } content: {
            channelContent
                .navigationSplitViewColumnWidth(min: 380, ideal: 480)
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

    // MARK: - Country sidebar

    private var countrySidebar: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            List(selection: $viewModel.countryFilter) {
                Label("All Countries", systemImage: "globe")
                    .tag(String?.none)

                if !defaultCountries.isEmpty {
                    Section("Default Countries") {
                        ForEach(defaultCountries, id: \.self) { country in
                            countryRow(country)
                        }
                    }
                }

                Section("Countries") {
                    ForEach(otherCountries, id: \.self) { country in
                        countryRow(country)
                    }
                }
            }
        }
        .navigationTitle("Countries")
    }

    private var defaultCountries: [String] {
        viewModel.availableCountries.filter(countryPreferences.isDefault)
    }

    private var otherCountries: [String] {
        viewModel.availableCountries.filter { !countryPreferences.isDefault($0) }
    }

    private func countryRow(_ country: String) -> some View {
        HStack {
            Text(country)
            Spacer()
            Button {
                countryPreferences.toggleDefault(country)
            } label: {
                Image(systemName: countryPreferences.isDefault(country) ? "star.fill" : "star")
                    .foregroundStyle(countryPreferences.isDefault(country) ? .yellow : .secondary)
            }
            .buttonStyle(.plain)
        }
        .tag(String?.some(country))
    }

    // MARK: - Channel content

    private var channelContent: some View {
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
        .navigationTitle(viewModel.countryFilter ?? "All Countries")
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
            if viewModel.alphabeticalChannels.isEmpty {
                ContentUnavailableView.search(text: viewModel.searchText)
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 16) {
                        ForEach(viewModel.alphabeticalChannels) { channel in
                            ChannelTileView(
                                channel: channel,
                                isSelected: viewModel.selectedChannel == channel
                            )
                            .onTapGesture {
                                viewModel.selectedChannel = channel
                            }
                        }
                    }
                    .padding(16)
                }
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search channels")
    }

    private var filterBar: some View {
        HStack {
            Toggle("Show only working channels", isOn: $viewModel.showOnlyWorkingChannels)
                .toggleStyle(.switch)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }

    // MARK: - Player detail

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
}
