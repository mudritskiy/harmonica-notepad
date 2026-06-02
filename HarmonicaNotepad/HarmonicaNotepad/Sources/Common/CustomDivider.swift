//
//  CustomDivider.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.03.2026.
//

import SwiftUI

struct CustomDivider: View {
    private let _color: ColorToken
    private let _width: CGFloat?
    private let _height: CGFloat?

    init(
        color: ColorToken = Theme.colors.background.highlight,
        width: CGFloat? = nil,
        height: CGFloat? = nil
    ) {
        _color = color
        _width = width
        _height = height
    }

    public var body: some View {
        _color.color
            .frame(width: _width, height: _height)
    }

    public static func horizontal(
        color: ColorToken = Theme.colors.text.secondary,
        lineWidth: CGFloat = 1
    ) -> some View {
        CustomDivider(
            color: color,
            height: lineWidth
        )
    }

    public static func vertical(
        color: ColorToken = Theme.colors.text.secondary,
        lineWidth: CGFloat = 1
    ) -> some View {
        CustomDivider(
            color: color,
            width: lineWidth
        )
    }
}
