//
//  Melody.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import Foundation
import MusicTheory
import SwiftData

@Model
final class Melody {
    var key: Key
    var bpm: Double
    var notesWrapped: [MelodyNoteWrapper]
    var song: HarmonicaSong?

    @Transient
    private var _notes: [MelodyNote] = []
    var notes: [MelodyNote] {
        get {
            guard _notes.isEmpty else { return _notes }
            let layout = HarmonicaLayout(key: key)
            let layoutNotes = layout.notes
            _notes = notesWrapped.compactMap { MelodyNote(storeNote: $0, notes: layoutNotes) }
            return _notes
        }
        set {
            _notes = newValue
        }
    }

    @Transient
    var tempo: Tempo = Tempo(bpm: Double(TempoStyle.andante.rawValue)) {
        didSet { bpm = tempo.bpm }
    }

    init(
        key: Key = .default,
        tempo: Tempo = Tempo(bpm: Double(TempoStyle.andante.rawValue)),
        notes: [MelodyNote] = []
    ) {
        self.key = key
        self.bpm = tempo.bpm
        self.tempo = tempo
        self.notesWrapped = notes.map { $0.wrappedValue }
        _notes = notes
    }
}
