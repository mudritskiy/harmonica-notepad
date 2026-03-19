//
//  CardContainer.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.10.2025.
//

import SwiftUI

public typealias Action = @MainActor () -> Void
public typealias ContainerContent<Content> = () -> Content

public struct CardContainer<Content: View>: View {
    let cornerRadius: CGFloat
    let borderWidth: CGFloat
    let backgroundColor: Color
    let borderColor: Color
    let content: Content

    // MARK: - Init
    public init(
        cornerRadius: CGFloat = 16,
        borderWidth: CGFloat = 1,
        backgroundColor: Color = .clear,
        borderColor: Color = .gray,
        @ViewBuilder content: ContainerContent<Content>
    ) {
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.content = content()
    }

    // MARK: - Render
    public var body: some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .strokeBorder(
                        borderColor,
                        lineWidth: borderWidth
                    )
            )
            .background(backgroundColor)
            .clipShape(
                RoundedRectangle(cornerRadius: cornerRadius)
            )
    }
}
