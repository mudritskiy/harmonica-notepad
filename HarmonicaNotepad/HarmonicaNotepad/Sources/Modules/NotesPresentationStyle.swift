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
    let layout = HarmonicaLayout.init(key: .default)
    let notes = layout.notes.prefix(15).map {
        MelodyNote(note: $0)
    }
    NotesPresentationView(notes: notes, style: .numbers)
}
