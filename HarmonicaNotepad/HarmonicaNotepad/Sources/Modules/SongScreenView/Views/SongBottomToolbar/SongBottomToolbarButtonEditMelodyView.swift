//
//  SongBottomToolbarButtonEditMelodyView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.03.2026.
//

import SwiftUI

struct SongBottomToolbarButtonEditMelodyView: View {
    // MARK: - State
    @State private var isAnimating: Bool = false

    // MARK: - Properties
    let onTap: Action

    // MARK: - Render
    var body: some View {
        _button()
    }

    private func _button() -> some View {
        Button(action: onTap) {
            _iconEdit()
        }
        .buttonStyle(.plain)
    }

    private func _iconEdit() -> some View {
        Image(systemName: "music.quarternote.3")
            .resizable()
            .frame(width: 28, height: 28)
            .padding(.all, 16)
            .foregroundStyle(Theme.colors.background.secondary.color)
            .background {
                ButtonBackgroundView()
            }
    }
}
