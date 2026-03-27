//
//  MelodyEditScreenViewModel.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 30.05.2025.
//

import Combine
import MusicTheory
import SwiftUI

enum MelodyEditScreenAssembly {
    static func makeViewModel(
        with melody: Melody
    ) -> MelodyEditScreenViewModel {
        MelodyEditScreenViewModel(
            melody: melody,
            playerService: .shared,
            melodyService: MelodyServiceImpl()
        )
    }
}

@Observable
final class MelodyEditScreenViewModel {
    // MARK: Depenencies
    private let _playerService: PlayerService
    private let _melodyService: MelodyService
    private let _pasteboard: UIPasteboard

    // MARK: - Published properties
    var showAlert = false
    var isPresentedKeySetup: Bool = false {
        didSet { _stopPlayingMelody(isPresentedKeySetup) }
    }
    var isPresentedTempoSetup: Bool = false {
        didSet { _stopPlayingMelody(isPresentedTempoSetup) }
    }
    var isPresentedLayoutConfiguration: Bool = false {
        didSet { _stopPlayingMelody(isPresentedLayoutConfiguration) }
    }

    // MARK: - Properties
    @ObservationIgnored var key: Key = .default
    @ObservationIgnored var notes: [MelodyNote] = []
    @ObservationIgnored var tempo: Tempo
    @ObservationIgnored var dismiss: (() -> Void)?

    var isPlayingMelody: Bool = false
    private(set) var alertInfo: AlertInfo = .empty()
    private(set) var melodyRows: [[MelodyNote]] = []

    private var _configuration: HarmonicaLayoutConfiguration
    private var _layout: HarmonicaLayout
    private var _playingNoteIndex: Int?
    private var notesGrid: HarmonicaLayoutNotesGrid

    private var _playbackTask: Task<Void, Never>?
    private var _cancellables = Set<AnyCancellable>()
    private var _serviceKeyboardTask: Task<Void, Never>?

    @ObservationIgnored let serviceKeyboardEvents = EventStream<ServiceKeyboardEvent>()
    @ObservationIgnored let melodyPublisher = PassthroughSubject<Melody, Never>()
    @ObservationIgnored var layoutViewProps: HarmonicaLayoutViewProps?

    // MARK: - Init
    init(
        melody: Melody,
        playerService: PlayerService,
        melodyService: MelodyService,
        pasteboard: UIPasteboard = .general,
        configuration: HarmonicaLayoutConfiguration = HarmonicaLayoutConfiguration()
    ) {
        _playerService = playerService
        _melodyService = melodyService
        _pasteboard = pasteboard

        let melodyKey = melody.key
        let layout = HarmonicaLayout(key: melodyKey)

        _configuration = configuration
        let notesGrid = layout.layoutGrid(with: configuration)
        self.notesGrid = notesGrid

        _layout = layout
        key = melodyKey
        notes = melody.notes
        tempo = melody.tempo

        _updateLayoutViewProps()
        _updateMelodyRows()
        _bindStates()
    }

    private func _updateLayoutViewProps() {
        let layoutViewProps = HarmonicaLayoutViewProps(
            congif: _configuration,
            notesGrid: notesGrid,
            font: .title3,
            serviceKeyboardEvents: serviceKeyboardEvents
        )  { [weak self] note in
            let melodyNote = MelodyNote(note: note, value: NoteValue(type: .quarter))
            self?._addAndPlayNote(melodyNote)
        }
        self.layoutViewProps = layoutViewProps
    }

    private func _bindStates() {
        _playerService.playingNoteIndexPublisher
            .sink { [weak self] index in
                self?._playingNoteIndex = index
            }
            .store(in: &_cancellables)

        _playerService.isPlayingMelodyPublisher
            .sink { [weak self] isPlayingMelody in
                withAnimation(.easeInOut(duration: 0.4)) {
                    self?.isPlayingMelody = isPlayingMelody
                }
            }
            .store(in: &_cancellables)
    }

    // MARK: - View Methods
    func isPlayingNote(rowIndex: Int, at indexInRow: Int) -> Bool {
        let indexInMelody = _indexInMelody(rowIndex: rowIndex, indexInRow: indexInRow)
        return indexInMelody == _playingNoteIndex
    }

    private func _indexInMelody(rowIndex: Int, indexInRow: Int) -> Int {
        guard rowIndex > 0, melodyRows.count - 1 > rowIndex else { return indexInRow }
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
        self.key = key
        _layout = HarmonicaLayout(key: key)
        updateNoteGrid(with: _layout)
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
    func onPlayTap() {
        guard !notes.isEmpty else { return }
        if _playerService.isPlayingMelody {
            _playerService.stopPlayingMelody()
        } else {
            _playerService.playMelody(notes, with: tempo)
        }
    }

    func onServiceKeyTap(_ key: ServiceKeyboardEvent) {
        switch key {
            case .addNewLine:
                _addServiceNote(MelodyNote.newLine)
            case .removeLast:
                _removeLastNote()
            case .showSettings:
                isPresentedLayoutConfiguration = true
            case .addSpace:
                _addServiceNote(MelodyNote.silence)
        }
    }

    private func _addServiceNote(_ note: MelodyNote) {
        notes.append(note)
        _updateMelodyRows()
    }

    private func _removeLastNote() {
        guard !notes.isEmpty else { return }
        notes.removeLast()
        _updateMelodyRows()
    }

    func onClearTap() {
        _playerService.stopPlayingMelody()
        notes.removeAll()
        _updateMelodyRows()
    }

    // MARK: - Toolbar actions
    func onPasteTap() {
        defer {
            showAlert = true
        }

        guard let text = _pasteboard.string else {
            alertInfo = AlertInfo(
                title: "Nothing to paste",
                message: "Empty pasteboard",
                buttons: []
            )
            return
        }

        let notes = _melodyService.parseNotes(from: text, baseNotes: _layout.notes)
        guard !notes.isEmpty else {
            alertInfo = AlertInfo(
                title: "Invalid text",
                message: "Copied text cannot be parsed as a melody",
                buttons: []
            )
            return
        }

        alertInfo = AlertInfo(
            title: "Paste melody?",
            message: "This will discard your current changes",
            buttons: [
                AlertButton("Apply", role: .confirm) { [weak self] in
                    self?.notes = notes
                    self?._updateMelodyRows()
                },
                AlertButton("Cancel", role: .cancel) { [weak self] in
                    self?.showAlert = false
                }
            ]
        )
    }

    func onApplyTap() {
        alertInfo = AlertInfo(
            title: "Apply changes?",
            message: "Do you want to apply the changes you made?",
            buttons: [
                AlertButton("Apply", role: .confirm) { [weak self] in
                    self?._applyMelody()
                },
                AlertButton("Keep Editing", role: .none) { [weak self] in
                    self?.showAlert = false
                }
            ]
        )
        showAlert = true
    }

    private func _applyMelody() {
        _updateMelody()
        dismiss?()
    }

    private func _updateMelody() {
        let melody = Melody(
            key: key,
            tempo: tempo,
            notes: notes
        )
        melodyPublisher.send(melody)
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

    private func _updateMelodyRows() {
        melodyRows = _melodyService.breakInRows(notes: notes)
    }

    func melodyToolbarViewProps() -> MelodyToolbarViewProps {
        MelodyToolbarViewProps(
            isPlaying: isPlayingMelody,
            tempoTitle: "\(Int(tempo.bpm))",// bpm",
            keyTitle: key.description,
            onPlayTap: onPlayTap,
            onClearTap: onClearTap,
            onTempoTap: onTempoTap,
            onKeyTap: onKeyTap
        )
    }

    // MARK: -
    func applyConfiguration(with congif: HarmonicaLayoutConfiguration) {
        _configuration = congif
        updateNoteGrid(with: _layout)
    }

    func updateNoteGrid(with layout: HarmonicaLayout) {
        notesGrid = layout.layoutGrid(with: _configuration)
        _updateLayoutViewProps()
    }
}
