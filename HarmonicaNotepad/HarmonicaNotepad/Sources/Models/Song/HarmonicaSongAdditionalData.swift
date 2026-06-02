//
//  HarmonicaSongAdditionalData.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 12.04.2026.
//

import Foundation

struct SongAdditionalData: Codable, Equatable, Hashable {
    private var storage: [SongAdditionalKey: AnyCodable] = [:]

    // Generic access (type-safe)
    mutating func set<T: Encodable>(_ value: T?, for key: SongAdditionalKey) {
        if let value = value {
            storage[key] = AnyCodable(value)
        } else {
            storage.removeValue(forKey: key)
        }
    }

    func get<T: Decodable>(for key: SongAdditionalKey) -> T? {
        storage[key]?.value as? T
    }

    enum CodingKeys: String, CodingKey {
        case storage
    }
}
