//
//  HoleCell.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 20.06.2025.
//

import SwiftUI

struct HoleCell: View {
    let note: HarmonicaNote
    let color: Color
    let onTap: () -> Void

    let font: FontToken
    let keySize: CGSize

    init(
        note: HarmonicaNote,
        font: FontToken,
        keySize: CGSize,
        onTap: @escaping () -> Void
    ) {
        self.note = note
        self.onTap = onTap
        color = switch note.technique {
            case .natural:
                switch note.direction {
                    case .blow: Theme.colors.background.blow.color
                    case .draw: Theme.colors.background.draw.color
                }
            case .bend:
                switch note.direction {
                    case .blow: Theme.colors.background.blow.color.opacity(0.7)
                    case .draw: Theme.colors.background.draw.color.opacity(0.7)
                }
            case .overblow, .overdraw: Theme.colors.text.tertiary.color
        }

        self.font = font
        self.keySize = keySize
    }

    var body: some View {
        SwiftUI.Button(role: .none) {
            onTap()
        } label: {
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
