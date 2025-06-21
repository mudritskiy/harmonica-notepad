//
//  SwiftUI+Debug.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.06.2025.
//

import SwiftUI

public extension View {
    func debugBorder() -> some View {
        self.modifier(RandomColorBorder())
    }
}

private struct RandomColorBorder: ViewModifier {
    @State private var color = Color.randomVisible()
    @State private var isBackgroundActive = false
    private var _backgroundColor: Color {
        isBackgroundActive ? color.opacity(0.25) : Color.clear
    }

    func body(content: Content) -> some View {
        content
            .background(_backgroundColor)
            .border(color, width: 1)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isBackgroundActive.toggle()
                }
            }
    }
}

private extension Color {
    static func randomVisible() -> Color {
        let hue = Double.random(in: 0...1)
        let saturation = Double.random(in: 0.5...1) // Ensure some saturation
        let brightness = Double.random(in: 0.7...1) // Ensure brightness
        return Color(hue: hue, saturation: saturation, brightness: brightness)
    }
}
