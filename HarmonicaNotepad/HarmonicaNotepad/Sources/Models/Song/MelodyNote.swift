//
//  MelodyNote.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import MusicTheory
import SwiftData

@Model
final class MelodyNote: Sendable {
    var type: MelodyNoteType
    var note: HarmonicaNote
    var value: NoteValue { _valueWrapped.wrappedValue }
    private var _valueWrapped: NoteValueWrapper

    init(
        type: MelodyNoteType = .normal,
        note: HarmonicaNote,
        value: NoteValue
    ) {
        self.type = type
        self.note = note
        self._valueWrapped = NoteValueWrapper(value)
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

enum MelodyNoteType: Int, Codable {
    case normal
    case silence
    case newLine
}
