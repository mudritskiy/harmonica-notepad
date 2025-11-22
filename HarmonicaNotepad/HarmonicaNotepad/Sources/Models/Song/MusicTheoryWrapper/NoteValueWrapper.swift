//
//  NoteValueWrapper.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 03.07.2025.
//

import MusicTheory

struct NoteValueWrapper: Codable {
    let type: NoteValueTypeWrapper
    let modifier: NoteModifier.RawValue

    var value: NoteValue {
        NoteValue(
            type: type.value,
            modifier: NoteModifier(rawValue: modifier) ?? .default
        )
    }

    init(_ value: NoteValue) {
        self.type = NoteValueTypeWrapper(value.type)
        self.modifier = value.modifier.rawValue
    }
}
