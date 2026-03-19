//
//  Palette.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.03.2026.
//

import UIKit

struct Palette {
    // MARK: - Sand (background scale)
    let sand10: UIColor
    let sand20: UIColor
    let sand40: UIColor
    let sand60: UIColor

    // MARK: - Slate (accent)
    let slate50: UIColor

    // MARK: - Text neutrals
    let ink90: UIColor
    let ink60: UIColor
}

extension Palette {
    static let light = Palette(
        sand10: UIColor(hex: "f8f7f3"),
        sand20: UIColor(hex: "f4efe6"),
        sand40: UIColor(hex: "eedcb9"),
        sand60: UIColor(hex: "e3c78a"),
        slate50: UIColor(hex: "899aad"),

        ink90: UIColor(hex: "1A1A1A"),
        ink60: UIColor(hex: "6B6B6B")
    )
}

extension Palette {
    static let dark = Palette(
        sand10: UIColor(hex: "0f1115"),
        sand20: UIColor(hex: "14181d"),
        sand40: UIColor(hex: "2a2f36"),
        sand60: UIColor(hex: "3a3326"),
        slate50: UIColor(hex: "c2ccd6"),

        ink90: UIColor(hex: "F2F2F2"),
        ink60: UIColor(hex: "A0A0A0")
    )
}
