//
//  MelodyNoteWrapper.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.10.2025.
//

import MusicTheory

struct MelodyNoteWrapper: Codable {
    var type: MelodyNoteType
    let position: HarmonicaNotePosition
    let value: NoteValueWrapper

    func value(from notes: [HarmonicaNote]) -> MelodyNote? {
        switch type {
            case .normal:
                guard let note = notes.first(where: { $0.position == self.position }) else { return nil }
                return MelodyNote(
                    type: type,
                    note: note,
                    value: value.value
                )
            case .silence:
                return .silence
            case .newLine:
                return .newLine
        }
    }
}

extension MelodyNoteWrapper {
    init(_ value: MelodyNote) {
        self.init(
            type: value.type,
            position: value.note.position,
            value: NoteValueWrapper(value.value)
        )
    }
}

extension Array where Element == MelodyNoteWrapper {
    func values(for key: Key) -> [MelodyNote] {
        let layout = HarmonicaLayout(key: key)
        let layoutNotes = layout.notes
        let notes = self.compactMap { $0.value(from: layoutNotes) }
        return notes
    }
}
