//
//  Identified.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 01.07.2025.
//

struct Identified<Owner>: Hashable, Equatable, Codable {
    let rawValue: String

    init(_ rawValue: String) {
        self.rawValue = rawValue
    }
}
