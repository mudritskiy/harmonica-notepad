//
//  MelodyWrapper.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.10.2025.
//

import MusicTheory

struct MelodyWrapper: Codable {
    var key: Key
    var bpm: Double
    var notesWrapped: [MelodyNoteWrapper]

    var value: Melody {
        Melody(
            key: key,
            tempo: Tempo(bpm: bpm),
            notes: notesWrapped.values(for: key)
        )
    }

    var notes: [MelodyNote] {
        notesWrapped.values(for: key)
    }
}

extension MelodyWrapper {
    init(_ value: Melody) {
        self.init(
            key: value.key,
            bpm: value.tempo.bpm,
            notesWrapped: value.notes.map { MelodyNoteWrapper($0) }
        )
    }
}
