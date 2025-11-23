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

    // MARK: - View Context
    var modelContext: ModelContext? = nil
    var dismiss: (() -> Void)?

    // MARK: - Properties
    var song: HarmonicaSong
    var notes: [MelodyNote]
    private(set) var hasUnsavedChanges: Bool = false
    @ObservationIgnored let melodyEditScreenViewModel: MelodyEditScreenViewModel
    @ObservationIgnored let songEditScreenViewModel: SongEditScreenViewModel
    private var _cancellables = Set<AnyCancellable>()

    // MARK: - Init
    init(
        song: HarmonicaSong,
        playerService: PlayerService = .shared
    ) {
        _playerService = playerService

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
                self?.dismiss?()
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
    func onPlayTap() {
        guard !notes.isEmpty else { return }
        if _playerService.isPlayingMelody {
            _playerService.stopPlayingMelody()
        } else {
            _playerService.playMelody(
                notes,
                with: Tempo(bpm: song.melody.bpm)
            )
        }
    }

    func save() {
        guard let container = modelContext?.container else { return }
        Task.detached(priority: .background) {
            let actor = SongService(modelContainer: container)
            await actor.save(self.song)
        }
    }
}
