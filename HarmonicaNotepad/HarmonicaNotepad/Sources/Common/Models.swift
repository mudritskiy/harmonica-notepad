//
//  Models.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 25.05.2025.
//

import Foundation
import MusicTheory

// MARK: - Breath Direction & Techniques

extension String {
    static let empty = ""
    static let degree = "\u{00B0}" // Same as "°"
    static let apostrophe = "\u{0027}" // Same as "'"
    static let minus = "-"
}

enum BreathDirection: Int, CustomStringConvertible {
    case blow = 1
    case draw

    var description: String {
        switch self {
            case .blow: .empty
            case .draw: .minus
        }
    }
}

enum NoteTechnique: Equatable, Identifiable, CustomStringConvertible {
    enum BendLevel: Int, Comparable, CaseIterable {
        case none
        case level1
        case level2
        case level3

        var description: String {
            switch self {
                case .none: ""
                default: String(self.rawValue)
            }
        }

        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.rawValue < rhs.rawValue
        }
    }

    case natural
    case bend(BendLevel)
    case overblow
    case overdraw

    var id: Int {
        switch self {
            case .natural: 1
            case .overblow: 2
            case .overdraw: 3
            case .bend(let level): 3 + level.rawValue
        }
    }

    var description: String {
        switch self {
            case.natural: .empty
            case .bend(let level): String(repeating: .apostrophe, count: level.rawValue)
            case .overblow, .overdraw: .degree
        }
    }
}

// MARK: - HarmonicaNoteID with Bitmask Encoding/Decoding
struct HarmonicaNoteId: Hashable, Equatable {
    let rawValue: Int

    // Encoding layout:
    // bits 8...15: hole (8 bits)
    // bits 4...7: technique (4 bits)
    // bits 0...3: direction (4 bits)

    init(hole: Int, technique: NoteTechnique, direction: BreathDirection) {
        self.rawValue =
        (hole << 8) |
        (technique.id << 4) |
        direction.rawValue
    }
}

// MARK: - Harmonica Note Model
struct HarmonicaNote: Equatable {
    var id: HarmonicaNoteId {
        HarmonicaNoteId(
            hole: hole,
            technique: technique,
            direction: direction
        )
    }

    let hole: Int
    let direction: BreathDirection
    let technique: NoteTechnique
    let basePitch: Pitch

    var midiNote: UInt8 {
        UInt8(clamping: basePitch.rawValue)
    }

    var velocity: UInt8 {
        switch technique {
            case .natural: return 80
            case .bend: return 90
            case .overblow, .overdraw: return 100
        }
    }

    var description: String {
        "\(direction.description)\(hole)\(technique.description)"
    }
}

// MARK: - Harmonica Layout
struct HarmonicaLayout {
    var key: Key
    let notes: [HarmonicaNote]

    init(key: Key) {
        self.key = key
        self.notes = HarmonicaLayout.generateNotes(for: key)
    }

    static let baseLayout: [(hole: Int, direction: BreathDirection, technique: NoteTechnique, pitch: Pitch)] = [
        // Hole 1
        (1, .blow, .natural, Pitch(key: Key(type: .c), octave: 4)),
        (1, .draw, .natural, Pitch(key: Key(type: .d), octave: 4)),
        (1, .draw, .bend(.level1), Pitch(key: Key(type: .d, accidental: .flat), octave: 4)),
        (1, .blow, .overblow, Pitch(key: Key(type: .e, accidental: .flat), octave: 4)),

        // Hole 2
        (2, .blow, .natural, Pitch(key: Key(type: .e), octave: 4)),
        (2, .draw, .natural, Pitch(key: Key(type: .g), octave: 4)),
        (2, .draw, .bend(.level1), Pitch(key: Key(type: .g, accidental: .flat), octave: 4)),
        (2, .draw, .bend(.level2), Pitch(key: Key(type: .f), octave: 4)),

        // Hole 3
        (3, .blow, .natural, Pitch(key: Key(type: .g), octave: 4)),
        (3, .draw, .natural, Pitch(key: Key(type: .b), octave: 4)),
        (3, .draw, .bend(.level1), Pitch(key: Key(type: .b, accidental: .flat), octave: 4)),
        (3, .draw, .bend(.level2), Pitch(key: Key(type: .a), octave: 4)),
        (3, .draw, .bend(.level3), Pitch(key: Key(type: .a, accidental: .flat), octave: 4)),

        // Hole 4
        (4, .blow, .natural, Pitch(key: Key(type: .c), octave: 5)),
        (4, .draw, .natural, Pitch(key: Key(type: .d), octave: 5)),
        (4, .draw, .bend(.level1), Pitch(key: Key(type: .d, accidental: .flat), octave: 5)),
        (4, .blow, .overblow, Pitch(key: Key(type: .e, accidental: .flat), octave: 5)),

        // Hole 5
        (5, .blow, .natural, Pitch(key: Key(type: .e), octave: 5)),
        (5, .draw, .natural, Pitch(key: Key(type: .f), octave: 5)),
        (5, .blow, .overblow, Pitch(key: Key(type: .g, accidental: .flat), octave: 5)),

        // Hole 6
        (6, .blow, .natural, Pitch(key: Key(type: .g), octave: 5)),
        (6, .draw, .natural, Pitch(key: Key(type: .a), octave: 5)),
        (6, .draw, .bend(.level1), Pitch(key: Key(type: .a, accidental: .flat), octave: 5)),
        (6, .blow, .overblow, Pitch(key: Key(type: .b, accidental: .flat), octave: 5)),

        // Hole 7
        (7, .blow, .natural, Pitch(key: Key(type: .c), octave: 6)),
        (7, .draw, .natural, Pitch(key: Key(type: .b), octave: 5)),
        (7, .draw, .overdraw, Pitch(key: Key(type: .d, accidental: .flat), octave: 6)),

        // Hole 8
        (8, .blow, .natural, Pitch(key: Key(type: .e), octave: 6)),
        (8, .draw, .natural, Pitch(key: Key(type: .d), octave: 6)),
        (8, .blow, .bend(.level1), Pitch(key: Key(type: .e, accidental: .flat), octave: 6)),

        // Hole 9
        (9, .blow, .natural, Pitch(key: Key(type: .g), octave: 6)),
        (9, .draw, .natural, Pitch(key: Key(type: .f), octave: 6)),
        (9, .blow, .bend(.level1), Pitch(key: Key(type: .g, accidental: .flat), octave: 6)),
        (9, .draw, .overdraw, Pitch(key: Key(type: .a, accidental: .flat), octave: 6)),

        // Hole 10
        (10, .blow, .natural, Pitch(key: Key(type: .c), octave: 7)),
        (10, .draw, .natural, Pitch(key: Key(type: .a), octave: 6)),
        (10, .blow, .bend(.level1), Pitch(key: Key(type: .b), octave: 6)),
        (10, .blow, .bend(.level2), Pitch(key: Key(type: .b, accidental: .flat), octave: 6)),
        (10, .draw, .overblow, Pitch(key: Key(type: .d, accidental: .flat), octave: 6))
    ]

    /// Generate notes for the specified key
    private static func generateNotes(for key: Key) -> [HarmonicaNote] {
        // For C key, we can use the base layout directly
        if key.type == .c && key.accidental == .natural {
            return Self.baseLayout.map { layout in
                HarmonicaNote(
                    hole: layout.hole,
                    direction: layout.direction,
                    technique: layout.technique,
                    basePitch: layout.pitch
                )
            }
        }

        // For other keys, transpose from C
        // Calculate semitone difference manually
        let semitoneMap: [Key.KeyType: Int] = [
            .c: 0, .d: 2, .e: 4, .f: 5, .g: 7, .a: 9, .b: 11
        ]

        let baseSemitones = semitoneMap[.c] ?? 0
        let targetSemitones = (semitoneMap[key.type] ?? 0) + key.accidental.rawValue
        let semitoneDifference = targetSemitones - baseSemitones

        // Use static interval constants
        let interval: Interval
        switch semitoneDifference {
            case 0: interval = Interval.P1
            case 1: interval = Interval.A1
            case 2: interval = Interval.M2
            case 3: interval = Interval.m3
            case 4: interval = Interval.M3
            case 5: interval = Interval.P4
            case 6: interval = Interval.A4
            case 7: interval = Interval.P5
            case 8: interval = Interval.m6
            case 9: interval = Interval.M6
            case 10: interval = Interval.m7
            case 11: interval = Interval.M7
            default: interval = Interval.P1 // fallback
        }

        return Self.baseLayout.map { layout in
            let transposedPitch = layout.pitch + interval

            return HarmonicaNote(
                hole: layout.hole,
                direction: layout.direction,
                technique: layout.technique,
                basePitch: transposedPitch
            )
        }
    }
}


struct Identified<Owner>: Hashable, Equatable {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}

// MARK: - Melody Model
typealias MelodyId = Identified<Melody>
struct Melody {
    let id: MelodyId
    var key: Key
    var tempo: Tempo
    var notes: [MelodyNote]

    init(
        key: Key,
        tempo: Tempo = Tempo(bpm: Double(TempoStyle.andante.rawValue)),
        notes: [MelodyNote] = []
    ) {
        self.id = MelodyId(UUID().uuidString)
        self.key = key
        self.tempo = tempo
        self.notes = notes
    }

    func duration(for note: MelodyNote) -> TimeInterval {
        tempo.duration(of: note.value)
    }
}

// MARK: - MedolyNote
struct MelodyNote {
    let type: MelodyNoteType
    let note: HarmonicaNote
    let value: NoteValue

    init(
        type: MelodyNoteType = .normal,
        note: HarmonicaNote,
        value: NoteValue
    ) {
        self.type = type
        self.note = note
        self.value = value
    }
}

extension MelodyNote {
    static let silence = MelodyNote(
        type: .silence,
        note: .default,
        value: NoteValue(type: .quarter)
    )

    static let newLine = MelodyNote(
        type: .newLine,
        note: .default,
        value: NoteValue(type: .quarter)
    )

    var isServiceNote: Bool {
        type == .silence || type == .newLine
    }
}

enum MelodyNoteType: Int {
    case normal
    case silence
    case newLine
}

extension HarmonicaNote {
    static let `default` = HarmonicaNote(
        hole: 1,
        direction: .blow,
        technique: .natural,
        basePitch: .init(key: Key(type: .c), octave: 4)
    )
}
