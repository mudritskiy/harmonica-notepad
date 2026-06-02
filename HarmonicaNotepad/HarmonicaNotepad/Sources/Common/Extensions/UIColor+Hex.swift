//
//  UIColor+Hex.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.03.2026.
//

import UIKit

extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: UInt64
        switch hex.count {
            case 6:
                (r, g, b) = (int >> 16, int >> 8 & 0xFF, int & 0xFF)
            default:
                (r, g, b) = (1, 1, 1)
        }

        self.init(
            red: CGFloat(r) / 255,
            green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255,
            alpha: 1
        )
    }
}
