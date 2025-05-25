//
//  Models.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 25.05.2025.
//

import MusicTheory

// MARK: - Breath Direction & Techniques

enum BreathDirection {
    case blow
    case draw
}

enum NoteTechnique: Equatable {
    case natural
    case bend(Int)      // bending level, e.g., 1, 2, 3
    case overblow
    case overdraw
}

// MARK: - Harmonica Note Model
struct HarmonicaNote: Identifiable, Equatable {
    let id: Int                 // Unique identifier
    let hole: Int               // Hole number (1...10)
    let direction: BreathDirection
    let technique: NoteTechnique
    let basePitch: Pitch        // Base pitch in C key (for example)
}

// MARK: - Harmonica Layout
struct HarmonicaLayout {
    let key: Key         // e.g. .C, .D, .G
    let notes: [HarmonicaNote]

    init(key: Key) {
        self.key = key
        self.notes = HarmonicaLayout.generateNotes(for: key)
    }

    private static let baseLayout: [(hole: Int, direction: BreathDirection, technique: NoteTechnique, pitch: Pitch)] = [
        // Hole 1
        (1, .blow, .natural, Pitch(key: Key(type: .c), octave: 4)),
        (1, .draw, .natural, Pitch(key: Key(type: .d), octave: 4)),
        (1, .draw, .bend(1), Pitch(key: Key(type: .d, accidental: .flat), octave: 4)),

        // Hole 2
        (2, .blow, .natural, Pitch(key: Key(type: .e), octave: 4)),
        (2, .draw, .natural, Pitch(key: Key(type: .g), octave: 4)),
        (2, .draw, .bend(1), Pitch(key: Key(type: .f), octave: 4)),

        // Hole 3
        (3, .blow, .natural, Pitch(key: Key(type: .g), octave: 4)),
        (3, .draw, .natural, Pitch(key: Key(type: .b), octave: 4)),
        (3, .draw, .bend(1), Pitch(key: Key(type: .b, accidental: .flat), octave: 4)),
        (3, .draw, .bend(2), Pitch(key: Key(type: .a), octave: 4)),

        // Hole 4
        (4, .blow, .natural, Pitch(key: Key(type: .c), octave: 5)),
        (4, .draw, .natural, Pitch(key: Key(type: .d), octave: 5)),
        (4, .draw, .bend(1), Pitch(key: Key(type: .d, accidental: .flat), octave: 5)),
        (4, .blow, .overblow, Pitch(key: Key(type: .e, accidental: .flat), octave: 5)),

        // Hole 5
        (5, .blow, .natural, Pitch(key: Key(type: .e), octave: 5)),
        (5, .draw, .natural, Pitch(key: Key(type: .f), octave: 5)),
        (5, .blow, .overblow, Pitch(key: Key(type: .g), octave: 5)),

        // Hole 6
        (6, .blow, .natural, Pitch(key: Key(type: .g), octave: 5)),
        (6, .draw, .natural, Pitch(key: Key(type: .a), octave: 5)),
        (6, .draw, .bend(1), Pitch(key: Key(type: .a, accidental: .flat), octave: 5)),
        (6, .blow, .overblow, Pitch(key: Key(type: .b, accidental: .flat), octave: 5)),

        // Hole 7
        (7, .blow, .natural, Pitch(key: Key(type: .c), octave: 6)),
        (7, .draw, .natural, Pitch(key: Key(type: .b), octave: 5)),
        (7, .draw, .overdraw, Pitch(key: Key(type: .c, accidental: .sharp), octave: 6)),

        // Hole 8
        (8, .blow, .natural, Pitch(key: Key(type: .e), octave: 6)),
        (8, .draw, .natural, Pitch(key: Key(type: .d), octave: 6)),
        (8, .blow, .bend(1), Pitch(key: Key(type: .e, accidental: .flat), octave: 6)),
        (8, .draw, .overdraw, Pitch(key: Key(type: .f), octave: 6)),

        // Hole 9
        (9, .blow, .natural, Pitch(key: Key(type: .g), octave: 6)),
        (9, .draw, .natural, Pitch(key: Key(type: .f), octave: 6)),
        (9, .blow, .bend(1), Pitch(key: Key(type: .g, accidental: .flat), octave: 6)),
        (9, .draw, .overdraw, Pitch(key: Key(type: .a, accidental: .flat), octave: 6)),

        // Hole 10
        (10, .blow, .natural, Pitch(key: Key(type: .c), octave: 7)),
        (10, .draw, .natural, Pitch(key: Key(type: .a), octave: 6)),
        (10, .draw, .bend(1), Pitch(key: Key(type: .a, accidental: .flat), octave: 6)),
        (10, .draw, .bend(2), Pitch(key: Key(type: .g), octave: 6)),
        (10, .draw, .bend(3), Pitch(key: Key(type: .g, accidental: .flat), octave: 6)),
        (10, .draw, .overdraw, Pitch(key: Key(type: .b, accidental: .flat), octave: 6))
    ]

    /// Generate notes for the specified key
    private static func generateNotes(for key: Key) -> [HarmonicaNote] {
        // For C key, we can use the base layout directly
        if key.type == .c && key.accidental == .natural {
            return Self.baseLayout.enumerated().map { (index, layout) in
                HarmonicaNote(
                    id: index,
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

        return Self.baseLayout.enumerated().map { (index, layout) in
            let transposedPitch = layout.pitch + interval

            return HarmonicaNote(
                id: index,
                hole: layout.hole,
                direction: layout.direction,
                technique: layout.technique,
                basePitch: transposedPitch
            )
        }
    }
}

// MARK: - Melody Model

struct Melody {
    let name: String
    let noteIDs: [HarmonicaNote.ID]   // Reference to notes by their IDs
}
