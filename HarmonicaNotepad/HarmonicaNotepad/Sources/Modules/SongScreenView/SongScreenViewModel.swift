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

    // MARK: - View Context
    let context: ModelContext

    // MARK: - Properties
    var song: HarmonicaSong
    var notes: [MelodyNote]

    @ObservationIgnored private(set) var hasUnsavedChanges: Bool = false
    @ObservationIgnored let melodyEditScreenViewModel: MelodyEditScreenViewModel
    @ObservationIgnored let songEditScreenViewModel: SongEditScreenViewModel

    private var _cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        song: HarmonicaSong? = nil,
        context: ModelContext,
        playerService: PlayerService = .shared,
        favoritesService: FavoritesService = FavoritesServiceImpl.shared
    ) {
        _playerService = playerService
        _favoritesService = favoritesService
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
        if isFavorited {
            _favoritesService.removeFavorite(by: song.id, in: context)
        } else {
            _favoritesService.addFavorite(by: song.id, in: context)
        }
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
