import SwiftUI

struct ContentView: View {
    @State private var healthStore = StreamHealthStore()
    @State private var countryPreferences = CountryPreferencesStore()
    @State private var viewModel = ChannelListViewModel()
    @State private var playerViewModel = PlayerViewModel()

    private let gridColumns = [GridItem(.adaptive(minimum: 132, maximum: 132), spacing: 14)]

    var body: some View {
        NavigationSplitView {
            countrySidebar
                .navigationSplitViewColumnWidth(min: 210, ideal: 240)
        } content: {
            channelContent
                .navigationSplitViewColumnWidth(min: 400, ideal: 500)
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
        .tint(Theme.accent)
        .background(Theme.background)
    }

    // MARK: - Country sidebar

    private var countrySidebar: some View {
        List(selection: $viewModel.countryFilter) {
            Label {
                Text("All Countries")
            } icon: {
                Image(systemName: "globe")
                    .foregroundStyle(Theme.accent)
            }
            .tag(String?.none)

            if !defaultCountries.isEmpty {
                Section("Favorites") {
                    ForEach(defaultCountries, id: \.self) { country in
                        CountrySidebarRow(
                            country: country,
                            isFavorite: true,
                            toggleFavorite: { countryPreferences.toggleDefault(country) }
                        )
                        .tag(String?.some(country))
                    }
                }
            }

            Section("All") {
                ForEach(otherCountries, id: \.self) { country in
                    CountrySidebarRow(
                        country: country,
                        isFavorite: false,
                        toggleFavorite: { countryPreferences.toggleDefault(country) }
                    )
                    .tag(String?.some(country))
                }
            }
        }
        .listStyle(.sidebar)
        .scrollContentBackground(.hidden)
        .background(Theme.background)
        .navigationTitle("Countries")
    }

    private var defaultCountries: [String] {
        viewModel.availableCountries.filter(countryPreferences.isDefault)
    }

    private var otherCountries: [String] {
        viewModel.availableCountries.filter { !countryPreferences.isDefault($0) }
    }

    // MARK: - Channel content

    private var channelContent: some View {
        Group {
            switch viewModel.loadState {
            case .loading:
                skeletonGrid
            case .failed:
                ContentUnavailableView {
                    Label("Couldn't load channels", systemImage: "wifi.exclamationmark")
                } description: {
                    Text("Check your connection and try again.")
                } actions: {
                    Button("Retry") {
                        Task { await viewModel.load() }
                    }
                    .buttonStyle(.borderedProminent)
                }
            case .loaded:
                channelGrid
            }
        }
        .background(Theme.background)
        .navigationTitle(viewModel.countryFilter ?? "All Countries")
    }

    private var skeletonGrid: some View {
        ScrollView {
            LazyVGrid(columns: gridColumns, spacing: 14) {
                ForEach(0 ..< 15, id: \.self) { _ in
                    SkeletonChannelTileView()
                }
            }
            .padding(20)
        }
    }

    private var channelGrid: some View {
        VStack(spacing: 0) {
            statusBar
            Divider()
                .overlay(Theme.stroke)

            if viewModel.displayChannels.isEmpty {
                if viewModel.searchText.isEmpty {
                    ContentUnavailableView {
                        Label("No channels", systemImage: "tv.slash")
                    } description: {
                        Text("No channels match the current filters.")
                    }
                } else {
                    ContentUnavailableView.search(text: viewModel.searchText)
                }
            } else {
                ScrollView {
                    LazyVGrid(columns: gridColumns, spacing: 14) {
                        ForEach(viewModel.displayChannels) { channel in
                            ChannelTileView(
                                channel: channel,
                                isSelected: viewModel.selectedChannel == channel
                            )
                            .onTapGesture {
                                viewModel.selectedChannel = channel
                            }
                        }
                    }
                    .padding(20)
                }
            }
        }
        .searchable(text: $viewModel.searchText, placement: .toolbar, prompt: "Search channels")
    }

    private var statusBar: some View {
        HStack(spacing: 12) {
            Text("\(viewModel.displayChannels.count) channels")
                .font(.system(size: 11, weight: .medium))
                .foregroundStyle(.secondary)
                .monospacedDigit()

            if viewModel.isProbing {
                HStack(spacing: 5) {
                    ProgressView()
                        .controlSize(.mini)
                    Text("Checking streams…")
                        .font(.system(size: 11))
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Toggle(isOn: $viewModel.showOnlyWorkingChannels) {
                Text("Working only")
                    .font(.system(size: 11, weight: .medium))
            }
            .toggleStyle(.switch)
            .controlSize(.mini)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .background(Theme.background)
    }

    // MARK: - Player detail

    private var detail: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if let channel = viewModel.selectedChannel {
                PlayerView(viewModel: playerViewModel)
                    .navigationTitle(channel.name)
            } else {
                VStack(spacing: 14) {
                    Image(systemName: "play.tv")
                        .font(.system(size: 44, weight: .light))
                        .foregroundStyle(Theme.accent.opacity(0.8))
                    Text("Select a channel to start watching")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

// MARK: - Sidebar row

private struct CountrySidebarRow: View {
    let country: String
    let isFavorite: Bool
    let toggleFavorite: () -> Void

    @State private var isHovering = false

    var body: some View {
        HStack {
            Text(country)
            Spacer()
            if isFavorite || isHovering {
                Button(action: toggleFavorite) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .font(.system(size: 11))
                        .foregroundStyle(isFavorite ? Theme.accent : .secondary)
                }
                .buttonStyle(.plain)
                .help(isFavorite ? "Remove from Favorites" : "Add to Favorites")
            }
        }
        .contentShape(Rectangle())
        .onHover { isHovering = $0 }
    }
}
