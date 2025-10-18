//
//  NoteValueTypeWrapper.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.10.2025.
//

import MusicTheory

struct NoteValueTypeWrapper: Codable, Hashable {
    /// Store only the rate
    var rate: Double

    /// Compute the NoteValueType instance on the fly
    var value: NoteValueType {
        NoteValueType(rate: rate, description: "")
    }

    /// Init from the original NoteValueType
    init(_ value: NoteValueType) {
        self.rate = value.rate
    }
}
