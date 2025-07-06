//
//  OnFirstAppear.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 05.07.2025.
//


import SwiftUI

private struct OnFirstAppear: ViewModifier {
    @State private var isAppeared = false

    let action: () -> Void

    // MARK: - render
    func body(content: Content) -> some View {
        content
            .onAppear {
                if !isAppeared {
                    action()
                    isAppeared = true
                }
            }
    }
}

public extension View {
    func onFirstAppear(action: @escaping () -> Void) -> some View {
        modifier(OnFirstAppear(action: action))
    }

    @ViewBuilder
    func `if`<Content: View>(_ conditional: Bool, content: (Self) -> Content) -> some View {
        if conditional {
            content(self)
        } else {
            self
        }
    }
}