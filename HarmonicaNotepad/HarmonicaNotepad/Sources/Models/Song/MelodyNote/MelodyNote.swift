//
//  MelodyNote.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import MusicTheory

enum MelodyNoteType: Int, Codable {
    case normal
    case silence
    case newLine
}

struct MelodyNote: Equatable {
    let type: MelodyNoteType
    let note: HarmonicaNote
    let value: NoteValue

    init(
        type: MelodyNoteType = .normal,
        note: HarmonicaNote,
        value: NoteValue = NoteValue(type: .quarter)
    ) {
        self.type = type
        self.note = note
        self.value = value
    }
}

// MARK: - Presets
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
