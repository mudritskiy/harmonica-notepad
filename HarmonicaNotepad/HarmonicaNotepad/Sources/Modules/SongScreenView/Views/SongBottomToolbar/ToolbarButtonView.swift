//
//  SongBottomToolbarButtonEditMelodyView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.03.2026.
//

import SwiftUI

struct ToolbarButtonView: View {
    // MARK: - Properties
    let icon: Image
    let onTap: Action

    // MARK: - Render
    var body: some View {
        _button()
    }

    private func _button() -> some View {
        Button(action: onTap) {
            _buttonContent()
        }
        .buttonStyle(.plain)
    }

    private func _buttonContent() -> some View {
        icon
            .resizable()
            .frame(width: 28, height: 28)
            .padding(.all, 16)
            .foregroundStyle(Theme.colors.background.secondary.color)
            .background {
                ButtonBackgroundView()
            }
    }
}
