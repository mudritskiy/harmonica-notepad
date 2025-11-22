//
//  Melody.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import MusicTheory

struct Melody {
    var key: Key
    var notes: [MelodyNote]
    var tempo: Tempo

    init(
        key: Key = .default,
        tempo: Tempo = Tempo(bpm: Double(TempoStyle.andante.rawValue)),
        notes: [MelodyNote] = []
    ) {
        self.key = key
        self.tempo = tempo
        self.notes = notes
    }
}
