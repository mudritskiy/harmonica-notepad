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
    var context: ModelContext?

    private(set) var isSongListVisible: Bool = false
    private(set) var listsWithSong: [SongsList] = []
    private(set) var listsWithSongWrappedItems: [WrappedTextListView.Item] = []
    private(set) var listsWithSongProps: WrappedTextListItemViewProps = WrappedTextListItemViewProps(
        color: Theme.colors.songList.textSelected,
        backgroundColor: Theme.colors.songList.backgoundSelected,
        borderColor: Theme.colors.songList.borderSelected,
        cornerRadius: 8,
        insets: EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8)
    )

    // MARK: - Properties
    var song: HarmonicaSong
    var notes: [MelodyNote]
    var songDuration: String {
        let duration = song.melody.value.duration()
        let result = _formattedDuration(from: duration)
        return result
    }
    var songCount: Int {
        song.melody.value.count
    }

    @ObservationIgnored private(set) var hasUnsavedChanges: Bool = false
    @ObservationIgnored let melodyEditScreenViewModel: MelodyEditScreenViewModel
    @ObservationIgnored let songEditScreenViewModel: SongEditScreenViewModel

    private var _cancellables = Set<AnyCancellable>()
    private var _playingTask: Task<Void, Never>?
    var isPlayingMelody: Bool = false

    let listSelectionProps: AutoSizingBottomSheetProps = AutoSizingBottomSheetProps(
        title: "Select lists",
        backgroundColor: Theme.colors.background.primary,
        dragIndicatorVisibility: .visible
    )

    // MARK: - Init
    init(
        song: HarmonicaSong? = nil,
        playerService: PlayerService = .shared,
        favoritesService: FavoritesService = FavoritesServiceImpl.shared,
        listsService: SongsListsService = SongsListsServiceImpl.shared
    ) {
        _playerService = playerService
        _favoritesService = favoritesService
        _listsService = listsService

        let song = song ?? .new()
        self.song = song
        self.notes = song.melody.notes

        melodyEditScreenViewModel = MelodyEditScreenAssembly.makeViewModel(with: song.melody.value)
        songEditScreenViewModel = SongEditScreenViewModel(song: song)

        _playingTask = Task {
            for await isPlaying in _playerService.isPlayingMelodyStream {
//                guard isPlayingMelody != isPlaying else { return }
                isPlayingMelody = isPlaying
            }
        }

        _bindStates()
    }

    deinit {
        _playingTask?.cancel()
        _playingTask = nil
        _playerService.stopPlayingMelody()
    }

    func fetchLists() {
        let songId = song.id
        let predicate = #Predicate<SongsListData> { data in
            data.songId == songId
        }

        let descriptor = FetchDescriptor<SongsListData>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.addedDate)]
        )

        let result = (try? context?.fetch(descriptor)) ?? []

        listsWithSong = result.compactMap { $0.songsList }
        listsWithSongWrappedItems = listsWithSong.map {
            WrappedTextListView.Item(text: $0.name) { }
        }
        isSongListVisible = !listsWithSong.isEmpty
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
        guard let context else { return }
        Task {
            context.insert(song)
            try? context.save()
            await MainActor.run {
                completion()
            }
        }
    }

    private func _formattedDuration(from time: TimeInterval) -> String {
        let totalSeconds = Int(time.rounded())

        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60

        var parts: [String] = []

        if hours > 0 {
            parts.append("\(hours) hour" + (hours == 1 ? "" : "s"))
        }

        if minutes > 0 {
            parts.append("\(minutes) m")
        }

        if seconds > 0 {
            parts.append("\(seconds) " + (minutes > 0 ? "s" : "sec"))
        }

        return parts.isEmpty ? "0 sec" : parts.joined(separator: " ")
    }
}
