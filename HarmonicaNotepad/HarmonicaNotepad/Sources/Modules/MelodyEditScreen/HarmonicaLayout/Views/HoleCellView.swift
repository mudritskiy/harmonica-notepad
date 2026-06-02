//
//  HoleCell.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.06.2025.
//

import SwiftUI

struct HoleCell: View {
    // MARK: - Properties
    let note: HarmonicaNote
    let color: Color
    let font: FontToken
    let keySize: CGSize

    let onTap: Action

    // MARK: - Init
    init(
        note: HarmonicaNote,
        font: FontToken,
        keySize: CGSize,
        onTap: @escaping () -> Void
    ) {
        self.note = note
        self.color = note.layoutColor
        self.font = font
        self.keySize = keySize
        self.onTap = onTap
    }

    // MARK: - Render
    var body: some View {
        Button(action: onTap) {
            _cellContent()
        }
    }

    private func _cellContent() -> some View {
        let border = note.technique == .overblow || note.technique == .overdraw
        return Text(note.basePitch.key.description)
            .font(font.value)
            .foregroundColor(border ? color : Theme.colors.text.contrastSecondary.color)
            .frame(width: keySize.width, height: keySize.height)
            .background(border ? Theme.colors.background.primaryTinted.color : color)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(color, lineWidth: 1)
            )
            .cornerRadius(8)
    }
}

// MARK: - HarmonicaNote Color
private extension HarmonicaNote {
    var layoutColor: Color {
        switch self.technique {
            case .natural:
                switch self.direction {
                    case .blow: Theme.colors.background.blow.color
                    case .draw: Theme.colors.background.draw.color
                }
            case .bend:
                switch self.direction {
                    case .blow: Theme.colors.background.blow.color.opacity(0.7)
                    case .draw: Theme.colors.background.draw.color.opacity(0.7)
                }
            case .overblow, .overdraw: Theme.colors.text.tertiary.color
        }
    }
}
