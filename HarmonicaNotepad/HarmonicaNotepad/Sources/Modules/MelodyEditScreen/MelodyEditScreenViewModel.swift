//
//  MelodyEditScreenViewModel.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.05.2025.
//

import Combine
import MusicTheory
import SwiftUI

final class MelodyEditScreenViewModel: ObservableObject {
    lazy var layoutViewModel: HarmonicaLayoutViewModel = HarmonicaLayoutViewModel(
        layout: layout,
        onNoteTap: { [weak self] note in
            let melodyNote = MelodyNote(note: note, value: NoteValue(type: .quarter))
            self?.addAndPlayNote(melodyNote)
        }
    )

    lazy var melodyActionPanelViewModel: MelodyActionPanelViewModel = MelodyActionPanelViewModel(
        playerService: playerService,
        onSilenceTap: { [weak self] in
            self?.melody.notes.append(.silence)
            self?.updateMelodyRows()
        },
        onNewLineTap: { [weak self] in
            self?.melody.notes.append(.newLine)
            self?.updateMelodyRows()
       },
        onDeleteTap: { [weak self] in
            self?._removeLastNote()
        },
        onPlayTap: { [weak self] in
            self?.onPlayTap()
        },
        onClearTap: { [weak self] in
            self?.onClearTap()
        }
    )

    let playerService = PlayerService()

    @Published var melody: Melody
    @Published var playingNoteIndex: Int?

    private var layout: HarmonicaLayout
    private let player = MidiNotePlayer()
    private var playbackTask: Task<Void, Never>?

    private var cancellables = Set<AnyCancellable>()

    var melodyRows: [[MelodyNote]] = []

    init() {
        layout = HarmonicaLayout(key: Key(type: .c))
        melody = Melody(key: layout.key)

        playerService.playingNoteIndexPublisher
            .sink { [weak self] index in
                self?.playingNoteIndex = index
            }
            .store(in: &cancellables)
    }

    private func addAndPlayNote(_ note: MelodyNote) {
        playbackTask?.cancel()
        playbackTask = Task {
            await addNote(note)
            await playerService.playNote(note, with: melody.tempo)
        }
    }

    @MainActor
    private func addNote(_ note: MelodyNote) {
        melody.notes.append(note)
        updateMelodyRows()
        playingNoteIndex = melody.notes.count - 1
    }

    private func _removeLastNote() {
        guard !melody.notes.isEmpty else { return }
        melody.notes.removeLast()
        updateMelodyRows()
    }

    func onPlayTap() {
        guard !melody.notes.isEmpty else { return }
        if playerService.isPlayingMelody {
            playerService.stopPlayingMeloday()
        } else {
            playerService.playMelody(melody)
        }
    }

    func onClearTap() {
        playerService.stopPlayingMeloday()
        melody.notes.removeAll()
        updateMelodyRows()
    }

    func isPlayingNote(rowIndex: Int, at indexInRow: Int) -> Bool {
        let indexInMelody = indexInMelody(rowIndex: rowIndex, indexInRow: indexInRow)
        return indexInMelody == playingNoteIndex
    }

    private func indexInMelody(rowIndex: Int, indexInRow: Int) -> Int {
        guard rowIndex > 0 else { return indexInRow }
        let notesCount = melodyRows.prefix(upTo: rowIndex).flatMap { $0 }.count
        return notesCount + indexInRow
    }

    @Published var isPresentedTempoSetup: Bool = false {
        didSet {
            if isPresentedTempoSetup {
                playerService.stopPlayingMeloday()
            }
        }
    }
    func onTempoTap() {
        isPresentedTempoSetup = true
    }

    func onTempoChange(to tempo: Tempo) {
        melody.tempo = tempo
        isPresentedTempoSetup = false
    }

    @Published var isPresentedKeySetup: Bool = false {
        didSet {
            if isPresentedKeySetup {
                playerService.stopPlayingMeloday()
            }
        }
    }
    func onKeyTap() {
        isPresentedKeySetup = true
    }

    func onKeyChange(to key: Key) {
        layout = HarmonicaLayout(key: key)
        layoutViewModel.updateNoteGrid(with: layout)
        melody.key = key
        isPresentedKeySetup = false
    }

    private func updateMelodyRows() {
        var result: [[MelodyNote]] = [melody.notes]
        while let lastRow = result.last,
              let splitIndex = lastRow.firstIndex(where: { $0.type == .newLine }) {
            let firstPart = Array(lastRow[..<splitIndex])
            let secondPart = Array(lastRow[(splitIndex+1)...])
            result.removeLast()
            result.append(contentsOf: [firstPart, secondPart])
        }
        melodyRows = result
    }
}


