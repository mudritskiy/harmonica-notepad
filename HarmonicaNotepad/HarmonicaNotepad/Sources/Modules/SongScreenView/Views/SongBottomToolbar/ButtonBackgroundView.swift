//
//  ButtonBackgroundView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 23.03.2026.
//

import SwiftUI

struct ButtonBackgroundView: View {
    let innerStrokeColor: Color
    let innerStrokeWidth: CGFloat = 1
    let innerStrokePadding: CGFloat = 0.5

    init(
        innerStrokeColor: Color = Theme.colors.background.accent.color
    ) {
        self.innerStrokeColor = innerStrokeColor
    }

    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(Theme.colors.background.accent.color)
                .themeShadow()
            Circle()
                .stroke(
                    Theme.colors.background.secondary.color,
                    lineWidth: innerStrokeWidth
                )
                .padding(innerStrokePadding)
        }
    }
}
