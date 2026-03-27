//
//  MelodyToolbarButtonKeyView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 26.03.2026.
//

import SwiftUI

struct MelodyToolbarButtonKeyView: View {
    // MARK: - Properties
    let title: String = "Key:"
    let subtitle: String
    let onTap: Action

    let size = MelodyToolbarButtonConstants.size

    // MARK: - Render
    var body: some View {
        _button()
    }

    private func _button() -> some View {
        Button(action: onTap) {
            _buttonContent()
                .frame(
                    width: size.width,
                    height: size.height,
                    alignment: .center
                )
                .background {
                    MelodyToolbarButtonBackgroundView()
                }
        }
        .buttonStyle(.plain)
    }

    private func _buttonContent() -> some View {
        HStack(
            alignment: .bottom,
            spacing: 4
        ) {
            Text(title)
                .font(FontToken.headline.value)
                .foregroundStyle(Theme.colors.text.secondary.color)
            Text(subtitle.uppercased())
                .font(FontToken.body2.value)
                .foregroundStyle(Theme.colors.text.secondary.color)
        }
    }
}
