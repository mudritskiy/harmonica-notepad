//
//  SongScreenViewModel.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 23.11.2025.
//

import Combine
import MusicTheory
import SwiftData
import SwiftUI

@Observable
final class SongScreenViewModel {
    enum Route: Hashable {
        case editSong
        case editMelody
    }

    // MARK: - Dependencies
    private let _playerService: PlayerService
    private var _songService: SongService?
    private let _favoritesService: FavoritesService
    let _listsService: SongsListsService

    // MARK: - View Context
    let context: ModelContext

    // MARK: - Properties
    var song: HarmonicaSong
    var notes: [MelodyNote]

    @ObservationIgnored private(set) var hasUnsavedChanges: Bool = false
    @ObservationIgnored let melodyEditScreenViewModel: MelodyEditScreenViewModel
    @ObservationIgnored let songEditScreenViewModel: SongEditScreenViewModel

    private var _cancellables = Set<AnyCancellable>()

    let listSelectionProps: AutoSizingBottomSheetProps = AutoSizingBottomSheetProps(
        title: "Оберіть список",
        backgroundColor: Theme.colors.background.primary,
        dragIndicatorVisibility: .visible
    )

    // MARK: - Init
    init(
        song: HarmonicaSong? = nil,
        context: ModelContext,
        playerService: PlayerService = .shared,
        favoritesService: FavoritesService = FavoritesServiceImpl.shared,
        listsService: SongsListsService = SongsListsServiceImpl.shared
    ) {
        _playerService = playerService
        _favoritesService = favoritesService
        _listsService = listsService
        self.context = context

        let song = song ?? .new()
        self.song = song
        self.notes = song.melody.notes

        melodyEditScreenViewModel = MelodyEditScreenAssembly.makeViewModel(with: song.melody.value)
        songEditScreenViewModel = SongEditScreenViewModel(song: song)

        _bindStates()
    }

    private func _bindStates() {
        melodyEditScreenViewModel.melodyPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] melody in
                self?.song.melody = MelodyWrapper(melody)
            }
            .store(in: &_cancellables)

        songEditScreenViewModel.songProperiesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] songProperties in
                self?._updateSong(with: songProperties)
            }
            .store(in: &_cancellables)
    }

    private func _updateSong(with songProperties: HarmonicaSongProperties) {
        song.artist = songProperties.artist
        song.comments = songProperties.comments
        song.title = songProperties.title
        hasUnsavedChanges = true
    }

    // MARK: - View Methods
    func onFavoriteTap(_ isFavorited: Bool) {
//        isListSelectionPresented.toggle()
//        if isFavorited {
//            _favoritesService.removeFavorite(by: song.id, in: context)
//        } else {
//            _favoritesService.addFavorite(by: song.id, in: context)
//        }
    }

    func onPlayTap() {
        guard !notes.isEmpty else { return }
        if _playerService.isPlayingMelody {
            _playerService.stopPlayingMelody()
        } else {
            let tempo = Tempo(bpm: song.melody.bpm)
            _playerService.playMelody(notes, with: tempo)
        }
    }

    func save(completion: @escaping () -> Void) {
        Task {
            context.insert(song)
            try? context.save()
            await MainActor.run {
                completion()
            }
        }
    }
}

import SwiftData
import SwiftUI

struct SongsListSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SongsList.name) private var songsLists: [SongsList]

    @State private var sortOption: SongsListsSortOption = .name

    var sortedLists: [SongsList] {
        switch sortOption {
            case .name:
                return songsLists.sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            case .count:
                return songsLists.sorted { $0.songsData.count > $1.songsData.count }
            case .lastAdded:
                return songsLists.sorted {
                    let date1 = $0.songsData.max(by: { $0.addedDate < $1.addedDate })?.addedDate ?? $0.createdDate
                    let date2 = $1.songsData.max(by: { $0.addedDate < $1.addedDate })?.addedDate ?? $1.createdDate
                    return date1 > date2
                }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedLists) { list in
                    NavigationLink(
                        destination: SongListDetailedView(songsListId: list.id)
                    ) {
                        SongsListRowView(songsList: list)
                    }
                    .listRowBackground(list.isDefault ? Color.blue.opacity(0.1) : Color.clear)
                }
            }
            .navigationTitle("My Harmonica Lists")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Menu {
                        ForEach(SongsListsSortOption.allCases) { option in
                            Button {
                                withAnimation {
                                    sortOption = option
                                }
                            } label: {
                                Label(option.rawValue, systemImage: sortIcon(for: option))
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
            }

        }
    }

    private func sortIcon(for option: SongsListsSortOption) -> String {
        sortOption == option ? "checkmark" : ""
    }


}

