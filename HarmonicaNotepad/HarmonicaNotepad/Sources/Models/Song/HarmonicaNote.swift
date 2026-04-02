//
//  HarmonicaNote.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import MusicTheory
import SwiftData

#warning("should be used instead of raw Int")
enum HarmonicaHole: Int, CaseIterable {
    case one = 1
    case two
    case three
    case four
    case five
    case six
    case seven
    case eight
    case nine
    case ten
}

struct HarmonicaNotePosition: Codable, Equatable {
    var hole: Int
    var direction: BreathDirection
    var technique: NoteTechnique
}

struct HarmonicaNote: Equatable {
    let position: HarmonicaNotePosition
    var basePitch: Pitch

    var hole: Int { position.hole }
    var direction: BreathDirection { position.direction }
    var technique: NoteTechnique { position.technique }

    var midiNote: UInt8 { UInt8(clamping: basePitch.rawValue) }

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

    init(hole: Int, direction: BreathDirection, technique: NoteTechnique, basePitch: Pitch) {
        self.position = HarmonicaNotePosition(
            hole: hole,
            direction: direction,
            technique: technique
        )
        self.basePitch = basePitch
    }
}

extension HarmonicaNote {
    static let `default`: HarmonicaNote = HarmonicaNote(
        hole: 1,
        direction: .blow,
        technique: .natural,
        basePitch: .default
    )

    static let maxPresentationSize: HarmonicaNote = HarmonicaNote(
        hole: 10,
        direction: .draw,
        technique: .bend(.level2),
        basePitch: .default
    )
}

extension Pitch {
    static var `default`: Pitch {
        Pitch(key: Key(type: .c), octave: 4)
    }
}

