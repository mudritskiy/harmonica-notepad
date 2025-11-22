//
//  TempoStyle.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 31.05.2025.
//

enum TempoStyle: Int, CaseIterable {
    case larghissimo = 20
    case grave       = 40
    case largo       = 60
    case adagio      = 76
    case andante     = 108
    case moderato    = 120
    case allegro     = 168
    case vivace      = 200
    case prestissimo = 300

    var presentation: String {
        switch self {
            case .larghissimo: "Larghissimo"
            case .grave:       "Grave"
            case .largo:       "Largo"
            case .adagio:      "Adagio"
            case .andante:     "Andante"
            case .moderato:    "Moderato"
            case .allegro:     "Allegro"
            case .vivace:      "Vivace"
            case .prestissimo: "Prestissimo"
        }
    }

    var valueRange: String {
        let all = Self.allCases
        if self == all.first {
            return "≤ \(rawValue) BPM"
        }

        if let previous = all.dropLast().last(where: { $0.rawValue < self.rawValue }) {
            let lowerBound = previous.rawValue + 1
            return "\(lowerBound)–\(rawValue) BPM"
        }

        return "≤ \(rawValue) BPM"
    }

    static func tempo(for bpm: Int) -> TempoStyle {
        TempoStyle.allCases.first(where: { bpm <= $0.rawValue }) ?? .largo
    }
}
