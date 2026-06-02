//
//  TextCursorView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 02.04.2026.
//

import SwiftUI

struct TextCursorView: View {
    let color: Color = Theme.colors.text.secondary.color
    let width: CGFloat = 2
    let height: CGFloat = 16
    let tailWidth: CGFloat = 6
    let tailHeight: CGFloat = 2
    let blinkDuration: Double = 0.8

    @State private var isVisible = true

    var body: some View {
        VStack(spacing: 0) {
            // Top tail
            Rectangle()
                .fill(color)
                .frame(width: tailWidth, height: tailHeight)

            // Main cursor
            Rectangle()
                .fill(color)
                .frame(width: width, height: height)

            // Bottom tail
            Rectangle()
                .fill(color)
                .frame(width: tailWidth, height: tailHeight)
        }
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(
                .easeOut(duration: blinkDuration)
                .repeatForever(autoreverses: true)
            ) {
                isVisible.toggle()
            }
        }
    }
}
