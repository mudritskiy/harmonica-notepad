//
//  ChipsView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 18.03.2026.
//

import SwiftUI

public struct ChipsProps: Hashable {
    let title: String
    let count: Int?
    let isAccessoryVisisble: Bool
    let isActive: Bool
    let onTap: Action

    public init(
        title: String,
        count: Int? = nil,
        isActive: Bool = false,
        isAccessoryVisisble: Bool = false,
        onTap: @escaping Action
    ) {
        self.title = title
        self.count = count
        self.isActive = isActive
        self.isAccessoryVisisble = isAccessoryVisisble
        self.onTap = onTap
    }

    public static func == (lhs: ChipsProps, rhs: ChipsProps) -> Bool {
        lhs.title == rhs.title
        && lhs.count == rhs.count
        && lhs.isActive == rhs.isActive
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.title)
    }
}

public struct ChipsView: View {
    private let _props: ChipsProps

    private let _cornerRadius: CGFloat
    private let _backgroundColor: ColorToken
    private let _borderColor: ColorToken

    // MARK: - Init
    public init(
        props: ChipsProps,
        cornerRadius: CGFloat = 20
    ) {
        _props = props
        _cornerRadius = cornerRadius
        _backgroundColor = _props.isActive ?
        Theme.colors.background.accent :
        Theme.colors.songList.backgound
        _borderColor = Theme.colors.songList.borderSelected
    }

    // MARK: - Render
    public var body: some View {
        Button(action: _props.onTap) {
            _titleContent()
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
                .background(_backgroundColor.color)
                .clipShape(
                    RoundedRectangle(cornerRadius: _cornerRadius)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: _cornerRadius)
                        .strokeBorder(
                            _borderColor.color,
                            lineWidth: 1
                        )
                }
        }
    }

    private func _titleContent() -> some View {
        HStack(
            alignment: .center,
            spacing: 8
        ) {
            Text(_props.title)
                .font(FontToken.body1.value)
                .foregroundStyle(Theme.colors.text.secondary.color)
            if let count = _props.count {
                Text(String(count))
                    .font(FontToken.body1.value)
                    .foregroundStyle(Theme.colors.text.secondary.color)
            }
            if _props.isAccessoryVisisble {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .fontWeight(.medium)
                    .tint(Theme.colors.text.accent.color)
            }
        }
    }
}
