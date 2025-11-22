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
    let fill: Bool
    let backgroundColor: Color
    let borderColor: Color
    let content: Content

    private let _cornerRadius: CGFloat = 16

    // MARK: - Init
    public init(
        fill: Bool = false,
        backgroundColor: Color = .clear,
        borderColor: Color = .gray,
        @ViewBuilder content: ContainerContent<Content>
    ) {
        self.fill = fill
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.content = content()
    }

    // MARK: - Render
    public var body: some View {
        content
            .padding(.all, _resolvedContentPadding)
            .background(
                RoundedRectangle(cornerRadius: _cornerRadius)
                    .stroke(borderColor, lineWidth: 1)
                    .background(backgroundColor)
            )
            .clipShape(
                RoundedRectangle(cornerRadius: _cornerRadius)
            )
    }

    private var _resolvedContentPadding: CGFloat {
        fill ? .zero : 16
    }
}
