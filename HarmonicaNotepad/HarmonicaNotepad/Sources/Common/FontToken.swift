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
    case body1
    case body2
    case caption
    case button
}

// MARK: - Internal Mapping
private extension FontToken {

    var fontInfo: FontInfo {
        switch self {
            case .largeTitle:
                return .init(.largeTitle, font: font(.bold, 34))
            case .title1:
                return .init(.title1, font: font(.bold, 28))
            case .title2:
                return .init(.title2, font: font(.medium, 22))
            case .title3:
                return .init(.title3, font: font(.medium, 20))
            case .headline:
                return .init(.headline, font: font(.medium, 17))
            case .body1:
                return .init(.body, font: font(.regular, 16))
            case .body2:
                return .init(.body, font: font(.regular, 14))
            case .caption:
                return .init(.caption1, font: font(.regular, 12))
            case .button:
                return .init(.callout, font: font(.medium, 16))
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

    enum Weight {
        case regular, medium, bold
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
}
