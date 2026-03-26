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
    let ink10: UIColor
    let ink30: UIColor
    let ink60: UIColor
    let ink90: UIColor

    let lavaBlack90: UIColor
    let lavaBlack70: UIColor
    let lavaBlack60: UIColor
    let lavaBlack10: UIColor

    let lavaBlackPersistant90: UIColor
    let lavaBlackPersistant70: UIColor
    let lavaBlackPersistant30: UIColor
    let lavaBlackPersistant10: UIColor

    // MARK: - Shadow
    let shadow: UIColor

    let neutral10: UIColor
    let neutral20: UIColor
    let sand30: UIColor
    let clay40: UIColor

    let draw: UIColor
    let blow: UIColor
}

extension Palette {
    static let light = Palette(
        sand10: UIColor(hex: "f8f7f3"),
        sand20: UIColor(hex: "f4efe6"),
        sand40: UIColor(hex: "eedcb9"),
        sand60: UIColor(hex: "e3c78a"),
        slate50: UIColor(hex: "899aad"),

        ink10: UIColor(hex: "100B37"),
        ink30: UIColor(hex: "6B6B6B"),
        ink60: UIColor(hex: "6B6B6B"),
        ink90: UIColor(hex: "1A1A1A"),

        lavaBlack90: UIColor(hex: "352f36"),
        lavaBlack70: UIColor(hex: "#4a414b"),
        lavaBlack60: UIColor(hex: "#544a55"),
        lavaBlack10: UIColor(hex: "#7d6f7f"),

        lavaBlackPersistant90: UIColor(hex: "#352f36"),
        lavaBlackPersistant70: UIColor(hex: "#aca2ae"),
        lavaBlackPersistant30: UIColor(hex: "#dbd7dc"),
        lavaBlackPersistant10: UIColor(hex: "#eeecee"),
//        lavaBlackOp60: UIColor(hex: "#d2ccd3"),

        shadow: UIColor(hex: "1A1A1A").withAlphaComponent(0.25),

        neutral10: UIColor(hex: "E3E3E3"),
        neutral20: UIColor(hex: "d9d9d9"),
        sand30: UIColor(hex: "EBE7D1"),
        clay40: UIColor(hex: "D19E90"),

        draw: UIColor(hex: "90a3d1"),
        blow: UIColor(hex: "d59faa")
    )
}

extension Palette {
    static let dark = Palette(
        sand10: UIColor(hex: "0f1115"),
        sand20: UIColor(hex: "14181d"),
        sand40: UIColor(hex: "2a2f36"),
        sand60: UIColor(hex: "3a3326"),
        slate50: UIColor(hex: "c2ccd6"),

        ink10: UIColor(hex: "CDC8F4"),
        ink30: UIColor(hex: "6B6B6B"),
        ink60: UIColor(hex: "A0A0A0"),
        ink90: UIColor(hex: "F2F2F2"),

        lavaBlack90: UIColor(hex: "#b6adb7"),
        lavaBlack70: UIColor(hex: "#c8c2ca"),
        lavaBlack60: UIColor(hex: "#d2ccd3"),
        lavaBlack10: UIColor(hex: "#87788a"),

        lavaBlackPersistant90: UIColor(hex: "#2b262c"),
        lavaBlackPersistant70: UIColor(hex: "#5e5460"),
        lavaBlackPersistant30: UIColor(hex: "#b6adb7"),
        lavaBlackPersistant10: UIColor(hex: "#eeecee"),

        shadow: UIColor(hex: "5A5A5A").withAlphaComponent(0.25),

        neutral10: UIColor(hex: "1C1C1C"),
        neutral20: UIColor(hex: "2C2C2C"),
        sand30: UIColor(hex: "7B6A53"), //2E2A14
        clay40: UIColor(hex: "6F3D2F"),

        draw: UIColor(hex: "2e416f"),
        blow: UIColor(hex: "6d303c")
    )
}
