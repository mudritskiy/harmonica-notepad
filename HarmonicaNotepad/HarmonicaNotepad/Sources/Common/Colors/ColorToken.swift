//
//  Untitled.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.03.2026.
//

import SwiftUI

struct ColorToken {
    private let uiColor: UIColor

    init(light: UIColor, dark: UIColor) {
        self.uiColor = UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        }
    }

    var color: Color {
        Color(uiColor)
    }
}

extension ColorToken {
    static func from(
        light: KeyPath<Palette, UIColor>,
        dark: KeyPath<Palette, UIColor>
    ) -> ColorToken {
        ColorToken(
            light: Palette.light[keyPath: light],
            dark: Palette.dark[keyPath: dark]
        )
    }
}
