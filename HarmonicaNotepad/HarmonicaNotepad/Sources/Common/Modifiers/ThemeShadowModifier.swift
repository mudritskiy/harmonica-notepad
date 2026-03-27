//
//  ThemeShadowModifier.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 23.03.2026.
//

import SwiftUI

enum ThemeShadowStyle {
    case primary
    case secondary

    fileprivate var props: ThemeShadowModifier.Props {
        switch self {
            case .primary:
                ThemeShadowModifier.Props(
                    radius: 1,
                    offset: CGPoint(x: 1, y: 1)
                )
            case .secondary:
                ThemeShadowModifier.Props(
                    radius: 2,
                    offset: CGPoint(x: 2, y: 2)
                )
        }
    }
}


private struct ThemeShadowModifier: ViewModifier {
    struct Props {
        let radius: CGFloat
        let offset: CGPoint
    }

    let props: Props
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
    func themeShadow(_ style: ThemeShadowStyle = .primary) -> some View {
        modifier(
            ThemeShadowModifier(props: style.props)
        )
    }
}
