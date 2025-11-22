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

    init(note: HarmonicaNote, onTap: @escaping () -> Void) {
        self.note = note
        self.onTap = onTap
        color = switch note.technique {
            case .natural:
                switch note.direction {
                    case .blow: .red.opacity(0.7)
                    case .draw: .blue.opacity(0.7)
                }
            case .bend:
                switch note.direction {
                    case .blow: .red.opacity(0.5)
                    case .draw: .blue.opacity(0.5)
                }
            case .overblow, .overdraw: .red
        }
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
            .font(.caption)
            .foregroundColor(border ? color : .white)
            .frame(minWidth: 30, maxWidth: .infinity, maxHeight: .infinity)
            .aspectRatio(1, contentMode: .fill)
            .background(border ? Color.clear : color)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(border ? color : Color.clear, lineWidth: 1)
            )
            .cornerRadius(6)
            .padding(.all, 2)
    }
}
