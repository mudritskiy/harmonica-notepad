//
//  HorizontalGeometryReader.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.03.2026.
//

import SwiftUI

public struct HorizontalGeometryReader<Content: View>: View {
    public var content: (CGFloat) -> Content
    @State private var width: CGFloat = 0

    public init(@ViewBuilder content: @escaping (CGFloat) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(width)
            .frame(minWidth: 0, maxWidth: .infinity)
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .preference(key: WidthPreferenceKey.self, value: geometry.size.width)
                }
            )
            .onPreferenceChange(WidthPreferenceKey.self) { width in
                self.width = width
            }
    }
}

private struct WidthPreferenceKey: @preconcurrency PreferenceKey, Equatable {
    @MainActor static var defaultValue: CGFloat = 0

    static func reduce(value _: inout CGFloat, nextValue _: () -> CGFloat) {}
}
