//
//  FontToken.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.03.2026.
//

import SwiftUI
import UIKit

// MARK: - Font Info
struct FontInfo {
    let textStyle: UIFont.TextStyle
    let font: UIFont

    init(_ textStyle: UIFont.TextStyle, font: UIFont) {
        self.textStyle = textStyle
        self.font = font
    }
}

// MARK: - FontToken
public enum FontToken: Sendable {
    case largeTitle
    case title1
    case title2
    case title3
    case headline
    case body0
    case body1
    case body2
    case caption
    case button
}

// MARK: - Internal Mapping
private extension FontToken {
    enum Weight {
        case regular, medium, bold
    }

    var fontInfo: FontInfo {
        switch self {
            case .largeTitle: FontInfo(.largeTitle, font: font(.bold, 34))
            case .title1: FontInfo(.title1, font: font(.bold, 28))
            case .title2: FontInfo(.title2, font: font(.medium, 22))
            case .title3: FontInfo(.title3, font: font(.medium, 20))
            case .headline: FontInfo(.headline, font: font(.medium, 18))
            case .body0: FontInfo(.body, font: font(.regular, 18))
            case .body1: FontInfo(.body, font: font(.regular, 16))
            case .body2: FontInfo(.body, font: font(.regular, 14))
            case .caption: FontInfo(.caption1, font: font(.regular, 12))
            case .button: FontInfo(.callout, font: font(.medium, 16))
        }
    }

    // Weight helper
    func font(_ weight: Weight, _ size: CGFloat) -> UIFont {
        let uiWeight: UIFont.Weight
        switch weight {
            case .regular: uiWeight = .regular
            case .medium:  uiWeight = .medium
            case .bold:    uiWeight = .bold
        }
        return UIFont.systemFont(ofSize: size, weight: uiWeight)
    }

    // Dynamic Type scaling
    func scaledFont() -> UIFont {
        let metrics = UIFontMetrics(forTextStyle: fontInfo.textStyle)
        return metrics.scaledFont(for: fontInfo.font)
    }
}

// MARK: - Public Access
public extension FontToken {

    /// UIFont for UIKit
    var uiFont: UIFont {
        scaledFont()
    }

    /// SwiftUI Font
    var value: SwiftUI.Font {
        SwiftUI.Font(uiFont)
    }

    func size(with text: String) -> CGFloat {
        text
            .size(withAttributes: [.font: self.uiFont])
            .width
    }
}
