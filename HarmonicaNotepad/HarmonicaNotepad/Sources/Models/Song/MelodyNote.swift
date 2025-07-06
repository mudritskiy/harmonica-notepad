//
//  MelodyNote.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

import MusicTheory
import SwiftData

struct MelodyNoteWrapper: Codable {
    var type: MelodyNoteType
    let position: HarmonicaNotePosition
    let value: NoteValueWrapper
}

struct MelodyNote: Sendable {
    let type: MelodyNoteType
    let note: HarmonicaNote

    private let _value: NoteValueWrapper
    var value: NoteValue { _value.wrappedValue }

    var wrappedValue: MelodyNoteWrapper {
        MelodyNoteWrapper(
            type: type,
            position:note.position,
            value: _value
        )
    }

    init(
        type: MelodyNoteType = .normal,
        note: HarmonicaNote,
        value: NoteValue = NoteValue(type: .quarter)
    ) {
        self.type = type
        self.note = note
        self._value = NoteValueWrapper(value)
    }

    init?(storeNote: MelodyNoteWrapper, notes: [HarmonicaNote]) {
        switch storeNote.type {
            case .normal:
                guard let note = notes.first(where: { $0.position == storeNote.position }) else { return nil }
                self.init(
                    type: storeNote.type,
                    note: note,
                    value: storeNote.value.wrappedValue
                )
            case .silence:
                self.init(
                    type: MelodyNote.silence.type,
                    note: MelodyNote.silence.note,
                    value: MelodyNote.silence.value
                )
            case .newLine:
                self.init(
                    type: MelodyNote.newLine.type,
                    note: MelodyNote.newLine.note,
                    value: MelodyNote.newLine.value
                )

        }
    }
}

// MARK: - Presets
enum MelodyNoteType: Int, Codable {
    case normal
    case silence
    case newLine
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

