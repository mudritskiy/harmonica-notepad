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
    // MARK: Depenencies
    private let _playerService = PlayerService()
    private let _melodyService = MelodyService()

    // MARK: - Published properties
    @Published var key: Key = .default
    @Published var notes: [MelodyNote] = []
    @Published var tempo: Tempo
    @Published var showAlert = false

    @Published var isPresentedKeySetup: Bool = false {
        didSet { _stopPlayingMelody(isPresentedKeySetup) }
    }
    @Published var isPresentedTempoSetup: Bool = false {
        didSet { _stopPlayingMelody(isPresentedTempoSetup) }
    }

    // MARK: - Properties
    var dismiss: (() -> Void)?
    private(set) var alertInfo: AlertInfo = .empty()
    private(set) var melodyRows: [[MelodyNote]] = []

    private let _onApplyTap: () -> Void
    private let _onApplyTap2: (Melody) -> Void
    private var _layout: HarmonicaLayout
    private var _playbackTask: Task<Void, Never>?
    private var _cancellables = Set<AnyCancellable>()
    private var _playingNoteIndex: Int? {
        didSet { objectWillChange.send() }
    }

    // MARK: - View Models
    private(set) lazy var layoutViewModel: HarmonicaLayoutViewModel = HarmonicaLayoutViewModel(
        layout: _layout,
        onNoteTap: { [weak self] note in
            let melodyNote = MelodyNote(note: note, value: NoteValue(type: .quarter))
            self?._addAndPlayNote(melodyNote)
        }
    )

    private(set) lazy var melodyActionPanelViewModel: MelodyActionPanelViewModel = MelodyActionPanelViewModel(
        playerService: _playerService,
        onSilenceTap: { [weak self] in
            self?.notes.append(.silence)
            self?._updateMelodyRows()
        },
        onNewLineTap: { [weak self] in
            self?.notes.append(.newLine)
            self?._updateMelodyRows()
        },
        onDeleteTap: { [weak self] in
            self?._removeLastNote()
        },
        onPlayTap: { [weak self] in
            self?._onPlayTap()
        },
        onClearTap: { [weak self] in
            self?._onClearTap()
        }
    )

    // MARK: - Init
    init(melody: Melody? = nil, onApplyTap: @escaping () -> Void, onApplyTap2: @escaping (Melody) -> Void) {
        _onApplyTap = onApplyTap
        _onApplyTap2 = onApplyTap2

        let melodyKey = melody?.key ?? .default
        key = melodyKey
        _layout = HarmonicaLayout(key: melodyKey)
        tempo = melody?.tempo ?? .default
        notes = melody?.notes ?? []
        _updateMelodyRows()

        _playerService.playingNoteIndexPublisher
            .sink { [weak self] index in
                self?._playingNoteIndex = index
            }
            .store(in: &_cancellables)
    }

    // MARK: - View Methoda
    func isPlayingNote(rowIndex: Int, at indexInRow: Int) -> Bool {
        let indexInMelody = _indexInMelody(rowIndex: rowIndex, indexInRow: indexInRow)
        return indexInMelody == _playingNoteIndex
    }

    private func _indexInMelody(rowIndex: Int, indexInRow: Int) -> Int {
        guard rowIndex > 0 else { return indexInRow }
        let notesCount = melodyRows.prefix(upTo: rowIndex).flatMap { $0 }.count
        return notesCount + indexInRow
    }

    func onTempoTap() {
        isPresentedTempoSetup = true
    }

    func onTempoChange(to tempo: Tempo) {
        self.tempo = tempo
        isPresentedTempoSetup = false
    }

    func onKeyTap() {
        isPresentedKeySetup = true
    }

    func onKeyChange(to key: Key) {
        _layout = HarmonicaLayout(key: key)
        layoutViewModel.updateNoteGrid(with: _layout)
        self.key = key
        isPresentedKeySetup = false
    }

    private func _stopPlayingMelody(_ shouldStop: Bool) {
        guard shouldStop else { return }
        _playerService.stopPlayingMelody()
    }

    // MARK: - Layout Actions
    private func _addAndPlayNote(_ note: MelodyNote) {
        _playbackTask?.cancel()
        _playbackTask = Task {
            await _addNote(note)
            await _playerService.playNote(note, with: tempo)
        }
    }

    @MainActor
    private func _addNote(_ note: MelodyNote) {
        notes.append(note)
        _updateMelodyRows()
        _playingNoteIndex = notes.count - 1
    }

    // MARK: - Action Panel
    private func _updateMelodyRows() {
        melodyRows = _melodyService.breakInRows(notes: notes)
    }

    private func _removeLastNote() {
        guard !notes.isEmpty else { return }
        notes.removeLast()
        _updateMelodyRows()
    }

    private func _onPlayTap() {
        guard !notes.isEmpty else { return }
        if _playerService.isPlayingMelody {
            _playerService.stopPlayingMelody()
        } else {
            _playerService.playMelody(notes, with: tempo)
        }
    }

    private func _onClearTap() {
        _playerService.stopPlayingMelody()
        notes.removeAll()
        _updateMelodyRows()
    }

    // MARK: - Toolbar actions
    func onApplyTap() {
        alertInfo = AlertInfo(
            title: "Apply changes?",
            message: "Do you want to apply the changes you made?",
            buttons: [
                AlertButton("Apply", role: .confirm) {
//                    self._onApplyTap()
                    self._applyMelody()
                    self.dismiss?()
                },
                AlertButton("Keep Editing", role: .none) {
                    self.showAlert = false
                }
            ]
        )
        showAlert = true
    }

    private func _applyMelody() {
        let melody = Melody(
            key: key,
            tempo: tempo,
            notes: notes
        )
        _onApplyTap2(melody)
    }

    func onCancelTap() {
        alertInfo = AlertInfo(
            title: "Discard changes?",
            message: "Your unsaved edits will be lost.",
            buttons: [
                AlertButton("Discard", role: .destructive) {
                    self.dismiss?()
                },
                AlertButton("Keep Editing", role: .cancel) {
                    self.showAlert = false
                }
            ]
        )
        showAlert = true
    }
}

final class MelodyService {
    func breakInRows(notes: [MelodyNote]) -> [[MelodyNote]] {
        var result: [[MelodyNote]] = [notes]
        while let lastRow = result.last,
              let splitIndex = lastRow.firstIndex(where: { $0.type == .newLine }) {
            let firstPart = Array(lastRow[..<splitIndex])
            let secondPart = Array(lastRow[(splitIndex+1)...])
            result.removeLast()
            result.append(contentsOf: [firstPart, secondPart])
        }
        return result
    }
}
