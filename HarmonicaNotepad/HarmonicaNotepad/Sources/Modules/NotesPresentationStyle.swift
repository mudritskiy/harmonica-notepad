//
//  NotesPresentationStyle.swift
//  HarmonicaNotepad
//
//  Created by Volodymyr Mudrik on 05.07.2025.
//

import SwiftUI

enum NotesPresentationStyle {
    case numbers
}

struct NotesPresentationView: View {
    private var _presentationStyle: NotesPresentationStyle = .numbers
    private var _notes: [MelodyNote]

    init(notes: [MelodyNote], style: NotesPresentationStyle) {
        _notes = notes
        _presentationStyle = style
    }

    var body: some View {
        switch _presentationStyle {
            case .numbers:
                NotesPresentationNumbersStyleView(
                    viewModel: NotesPresentationNumbersStyleViewModel(notes: _notes)
                )
        }
    }
}

#Preview {
    let preview = Preview()
    let notes = preview.sampleMelodyNotes()
    NotesPresentationView(notes: notes, style: .numbers)
}
