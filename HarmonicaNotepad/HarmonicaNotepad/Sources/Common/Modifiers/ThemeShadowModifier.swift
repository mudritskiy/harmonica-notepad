//
//  ThemeShadowModifier.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 23.03.2026.
//

import SwiftUI

private struct ThemeShadowModifier: ViewModifier {
    let radius: CGFloat = 2
    let offset: CGPoint = CGPoint(x: 2, y: 2)
    
    func body(content: Content) -> some View {
        content
            .shadow(
                color: Theme.colors.background.shadow.color,
                radius: 2
            )
            .shadow(
                color: Theme.colors.background.shadow.color,
                radius: 2,
                x: offset.x,
                y: offset.y
            )
    }
}

extension View {
    func themeShadow() -> some View {
        modifier(ThemeShadowModifier())
    }
}
