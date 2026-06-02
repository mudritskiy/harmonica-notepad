//
//  MelodyNotePresenetionNumberPrimaryView.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 31.03.2026.
//

import SwiftUI

struct MelodyNotePresenetionNumberPrimaryViewProps {
    let baseNote = HarmonicaNote.maxPresentationSize

    let baseFont: FontToken = .headline
    let techniqueFont: FontToken = .body2

    let directionWidth: CGFloat
    let holeWidth: CGFloat
    let techniqueWidth: CGFloat

    init() {
        self.directionWidth = baseFont.size(with: baseNote.direction.presentation)
        self.holeWidth = baseFont.size(with: String(baseNote.hole))
        self.techniqueWidth = techniqueFont.size(with: baseNote.technique.presentation)
    }
}

struct MelodyNotePresenetionNumberPrimaryView: View {
    let state: MelodyNotePresenetionState
    let props: MelodyNotePresenetionNumberPrimaryViewProps

    var body: some View {
        if state.type == .silence {
            _silentNoteContent()
        } else {
            _noteContent()
        }
    }

    private func _silentNoteContent() -> some View {
        HStack(alignment: .top, spacing: .zero) {
            _noteDirectionContent(with: .empty)
            _noteHoleContent(with: .space)
            _noteTechniqueContent(with: .empty)
        }
    }

    private func _noteContent() -> some View {
        HStack(alignment: .top, spacing: .zero) {
            _noteDirectionContent(with: state.note.direction.presentation)
            _noteHoleContent(with: state.note.hole.description)
            _noteTechniqueContent(with: state.note.technique.presentation)
        }
        .foregroundStyle(Theme.colors.text.secondary.color)
    }

    private func _noteDirectionContent(with text: String) -> some View {
        Text(text)
            .font(props.baseFont.value)
            .frame(width: props.directionWidth)
    }

    private func _noteHoleContent(with text: String) -> some View {
        Text(text)
            .font(props.baseFont.value)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .frame(width: props.holeWidth)
            .background(_background)
    }

    private func _noteTechniqueContent(with text: String) -> some View {
        Text(text)
            .font(props.techniqueFont.value)
            .lineLimit(1)
            .minimumScaleFactor(0.3)
            .frame(width: props.techniqueWidth)
    }

    private var _background: some View {
        RoundedRectangle(cornerRadius: 4)
            .fill(Theme.colors.background.accent.color)
            .opacity(state.isPlaying ? 1 : 0)
            .animation(.easeOut(duration: 0.4), value: state.isPlaying)
    }
}
