//
//  MelodyNoteSimpleCellView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 06.07.2025.
//

import SwiftUI

struct MelodyNoteSimpleCellView: View {
    let note: HarmonicaNote
    let isPlaying: Bool

    var body: some View {
        Text(note.presentation)
            .font(.system(size: 10))
            .cornerRadius(4)
            .padding(2)
            .frame(width: 25, height: 25, alignment: .center)
            .background(
                MelodyNoteSimpleCellViewBackground(isActive: isPlaying)
            )
            .aspectRatio(1, contentMode: .fit)
    }
}

struct MelodyNoteSimpleCellViewBackground: View {
    let isActive: Bool
    var body: some View {
        if isActive {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.3))
        } else {
            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.gray.opacity(0.3), lineWidth: 0.5)
        }

    }
}

#Preview {
    let note = HarmonicaNote(
        hole: 3,
        direction: .draw,
        technique: .bend(.level3),
        basePitch: .default
    )
    HStack(spacing: 8) {
        MelodyNoteSimpleCellView(note: .default, isPlaying: false)
        MelodyNoteSimpleCellView(note: note, isPlaying: true)
    }
}
