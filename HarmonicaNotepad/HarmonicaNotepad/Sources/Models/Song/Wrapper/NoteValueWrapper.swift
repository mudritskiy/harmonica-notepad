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

    init(_ value: NoteValue) {
        self.type = NoteValueTypeWrapper(value.type)
        self.modifier = value.modifier.rawValue
    }

    var wrappedValue: NoteValue {
        NoteValue(
            type: type.wrappedValue,
            modifier: NoteModifier(rawValue: modifier) ?? .default
        )
    }
}

struct NoteValueTypeWrapper: Codable, Hashable {
    /// Store only the rate
    var rate: Double

    /// Compute the NoteValueType instance on the fly
    var wrappedValue: NoteValueType {
        NoteValueType(rate: rate, description: "")
    }

    /// Init from the original NoteValueType
    init(_ wrappedValue: NoteValueType) {
        self.rate = wrappedValue.rate
    }
}
