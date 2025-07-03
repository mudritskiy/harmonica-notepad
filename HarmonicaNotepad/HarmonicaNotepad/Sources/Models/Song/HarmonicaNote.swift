//
//  HarmonicaNote.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import MusicTheory
import SwiftData

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

@Model
final class HarmonicaNote: Equatable {
    var id: HarmonicaNoteId {
        HarmonicaNoteId(
            hole: hole,
            technique: technique,
            direction: direction
        )
    }

    var hole: Int
    var direction: BreathDirection
    var technique: NoteTechnique
    var basePitchValue: Pitch.RawValue
    @Transient
    var basePitch: Pitch { Pitch(rawValue: basePitchValue) ?? .default }


    init(hole: Int, direction: BreathDirection, technique: NoteTechnique, basePitch: Pitch) {
        self.hole = hole
        self.direction = direction
        self.technique = technique
        self.basePitchValue = basePitch.rawValue
    }

    var midiNote: UInt8 {
        UInt8(clamping: basePitchValue)
    }

    var velocity: UInt8 {
        switch technique {
            case .natural: return 80
            case .bend: return 90
            case .overblow, .overdraw: return 100
        }
    }

    var presentation: String {
        "\(direction.presentation)\(hole)\(technique.presentation)"
    }
}

extension HarmonicaNote {
    static let `default` = HarmonicaNote(
        hole: 1,
        direction: .blow,
        technique: .natural,
        basePitch: .default
    )
}

extension Pitch {
    static var `default`: Pitch {
        Pitch(key: Key(type: .c), octave: 4)
    }
}

