//
//  AnyCodable.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 12.04.2026.
//

import Foundation

struct AnyCodable: Codable, Hashable, Equatable {
    let value: Any

    init(_ value: Any) {
        self.value = value
    }

    // MARK: - Equatable
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        // Compare by description as a safe fallback for mixed types
        String(describing: lhs.value) == String(describing: rhs.value)
    }

    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(String(describing: value))
    }

    // Encoding
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
            case let bool as Bool: try container.encode(bool)
            case let int as Int: try container.encode(int)
            case let double as Double: try container.encode(double)
            case let string as String: try container.encode(string)
            case let date as Date: try container.encode(date)
            case let array as [Any]: try container.encode(array.map(AnyCodable.init))
            case let dict as [String: Any]: try container.encode(dict.mapValues(AnyCodable.init))
            default:
                // For unsupported types, fall back to description or throw if you prefer strictness
                try container.encode(String(describing: value))
        }
    }

    // Decoding (simplified — extend as needed)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let bool = try? container.decode(Bool.self) { value = bool }
        else if let int = try? container.decode(Int.self) { value = int }
        else if let double = try? container.decode(Double.self) { value = double }
        else if let string = try? container.decode(String.self) { value = string }
        else if let date = try? container.decode(Date.self) { value = date }
        else if let array = try? container.decode([AnyCodable].self) { value = array.map(\.value) }
        else if let dict = try? container.decode([String: AnyCodable].self) { value = dict.mapValues(\.value) }
        else { value = try container.decode(String.self) }
    }
}
