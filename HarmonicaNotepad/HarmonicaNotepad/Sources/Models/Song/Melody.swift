//
//  Melody.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import Foundation
import MusicTheory
import SwiftData

// MARK: - Melody Model
typealias MelodyId = Identified<Melody>

@Model
final class Melody {
//    var id: SongId
    var key: Key
    
    var bpm: Double
    var notes: [MelodyNote]

    init(
//        id: SongId,
        key: Key,
        tempo: Tempo = Tempo(bpm: Double(TempoStyle.andante.rawValue)),
        notes: [MelodyNote] = []
    ) {
        //        self.id = MelodyId(UUID().uuidString)
//        self.id = id
        self.key = key
        self.tempo = tempo
        self.notes = notes
        self.bpm = tempo.bpm
    }

    @Transient
    var tempo: Tempo = Tempo(bpm: Double(TempoStyle.andante.rawValue)) {
        didSet { bpm = tempo.bpm }
    }

    func duration(for note: MelodyNote) -> TimeInterval {
        tempo.duration(of: note.value)
    }
}

//@Model
//final class MelodyDataModel {
//    @Attribute(.unique) var id: String //SongId
//    var key: Key
//    var tempo: Tempo
//    var notes: [MelodyNote]
//
//    init(
//        id: SongId,
//        key: Key,
//        tempo: Tempo,
//        notes: [MelodyNote]
//    ) {
//        self.id = id.rawValue
//        self.key = key
//        self.tempo = tempo
//        self.notes = notes
//    }
//}
